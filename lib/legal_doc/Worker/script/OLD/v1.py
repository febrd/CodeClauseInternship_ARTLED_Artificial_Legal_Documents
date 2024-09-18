import sys  
import os  
import json  
import fitz  
import pytesseract  
from PIL import Image  
from docx import Document  
from transformers import pipeline, AutoTokenizer  
import langdetect  
import warnings  

warnings.filterwarnings("ignore", category=FutureWarning, module='huggingface_hub')  
summarizer_model_name = "facebook/m2m100_418M"  
summarizer_tokenizer = AutoTokenizer.from_pretrained(summarizer_model_name)  
summarizer = pipeline("summarization", model=summarizer_model_name, tokenizer=summarizer_tokenizer)  
sentiment_analyzer = pipeline("sentiment-analysis", model="nlptown/bert-base-multilingual-uncased-sentiment")  
MAX_TOKENS = summarizer_tokenizer.model_max_length  

def detect_language(text):  
    try:  
        return langdetect.detect(text)  
    except langdetect.lang_detect_exception.LangDetectException:  
        return "unknown"  

def chunk_text(text, max_length):  
    tokens = summarizer_tokenizer(text, return_tensors='pt', truncation=False)  
    input_ids = tokens['input_ids'][0]  
    chunks = []  
    for i in range(0, len(input_ids), max_length):  
        chunk = input_ids[i:i + max_length]  
        chunks.append(chunk)  
    return [summarizer_tokenizer.decode(chunk, skip_special_tokens=True) for chunk in chunks]  

def analyze_document(content):  
    sentiments = []  
    chunks = chunk_text(content, MAX_TOKENS)  
    
    for chunk in chunks:  
        if len(chunk) == 0: 
            continue  
        
        lang = detect_language(chunk)  
        if lang == "unknown":  
            continue  
        
      
        chunk_tokens = summarizer_tokenizer(chunk, return_tensors='pt')['input_ids'][0]  
        if len(chunk_tokens) > MAX_TOKENS:  
            return "Limit Exceed", "The document is too complex to process within token limits."  
        
        sentiment = sentiment_analyzer(chunk)  
        sentiments.append(sentiment[0]['label'].lower())  

    if sentiments:  
        if "inappropriate" in sentiments:  
            return "inappropriate"  
        elif "negative" in sentiments:  
            return "negative"  
        elif "positive" in sentiments:  
            return "positive"  
        else:  
            return "neutral"  
    
    return "neutral"  

def generate_summary(content, input_lang):  
    summaries = []  
    chunks = chunk_text(content, MAX_TOKENS)  
    
    for chunk in chunks:  
        if len(chunk) == 0:  
            continue  
        
        try:  
            summary = summarizer(chunk, max_length=150, min_length=50, do_sample=False,   
                                 forced_bos_token_id=summarizer_tokenizer.lang_code_to_id.get(input_lang, -1))  
            if summary:  
                summaries.append(summary[0]['summary_text'])  
        except Exception as e:  
            return "Limit Exceed", str(e)  
    
    return " ".join(summaries) if summaries else "No summary available"  

def generate_title(content, input_lang):  
    try:  
        first_chunk = chunk_text(content[:512], MAX_TOKENS)[0]  
        summary = summarizer(first_chunk, max_length=50, min_length=10, do_sample=False,   
                             forced_bos_token_id=summarizer_tokenizer.lang_code_to_id.get(input_lang, -1))  
        title = summary[0]['summary_text'] if summary else "Title not available"  
    except Exception as e:  
        return "Limit Exceed", str(e) 
    
    if title == "Title not available":  
        first_sentence = content.split('.')[0] if '.' in content else content[:50]  
        return first_sentence.strip()  
    return title  

def extract_text_from_pdf(file_path):  
    text = ""  
    with fitz.open(file_path) as pdf:  
        for page in pdf:  
            text += page.get_text()  
            if not text.strip():  
                pix = page.get_pixmap()  
                img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)  
                text += pytesseract.image_to_string(img)  
    return text  

def extract_text_from_docx(file_path):  
    doc = Document(file_path)  
    text = "\n".join([para.text for para in doc.paragraphs])  
    return text  

def extract_text_from_txt(file_path):  
    with open(file_path, 'r', encoding='utf-8') as file:  
        text = file.read()  
    return text  

def process_document(file_path):  
    base_dir = "priv/static/assets/documents/"  
    full_path = os.path.join(base_dir, file_path)  
    ext = os.path.splitext(file_path)[1].lower()  
    
    try:  
        if ext == ".pdf":  
            content = extract_text_from_pdf(full_path)  
        elif ext == ".docx":  
            content = extract_text_from_docx(full_path)  
        elif ext == ".doc":  
            content = extract_text_from_docx(full_path)  
        elif ext == ".txt":  
            content = extract_text_from_txt(full_path)  
        else:  
            raise ValueError("Unsupported file type")  
        
        input_lang = detect_language(content)  

        sentiment = analyze_document(content)  
        if sentiment == "inappropriate":  
            title = "Document Not Processed"  
            summary = "This document contains inappropriate content and cannot be processed."  
        elif sentiment == "Limit Exceed":  
            title = "Processing Limit Exceeded"  
            summary = "The document is too complex to process due to token limits."  
        else:  
            summary = generate_summary(content, input_lang)  
            title = generate_title(content, input_lang)  
        
        result = {  
            "title": title,  
            "summary": summary,  
            "sentiment": sentiment,  
            "language": input_lang  
        }  
        print(json.dumps(result))  

    except Exception as e:  
        print(json.dumps({"error": str(e)}))  

if __name__ == "__main__":  
    if len(sys.argv) != 2:  
        print(json.dumps({"error": "Please provide the file name as an argument."}))  
    else:  
        file_name = sys.argv[1]  
        process_document(file_name)
