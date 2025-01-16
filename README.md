# A.R.T.L.E.D: Artificial Legal Document

This project showcases the power of **Natural Language Processing (NLP)** and **automation** using various tools and libraries. The application leverages **parallel processing** to optimize performance and uses the **Supervisor-Worker** model to ensure smooth and automated execution of tasks.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [License](#license)

---

## Overview
The goal of this project is to process and analyze text and document data using advanced NLP techniques and automation. By incorporating **parallel processing** and **Supervisor-Worker** patterns, the application achieves high efficiency and reliability.

---

## Features
- **Text Analysis**: Sentiment analysis, named entity recognition (NER), and keyword extraction.
- **Document Processing**: Extract text from PowerPoint (PPT or PPTX), spreadsheets (XLS or XLSX), CSV files, PDFs, Microsoft Word documents (DOC or DOCX), SQLite, and images attached to any file type.
- **Parallel Processing**: Tasks are distributed across multiple workers for faster execution.
- **Supervisor-Worker Model**: Automated task supervision and management ensure the application remains robust and error-tolerant.
- **Data Storage**: Processed data is stored in a PostgreSQL database for further analysis.

---

## Technologies Used

### Programming Languages & Frameworks
- **Python**: Core programming language for NLP and automation tasks.
- **Elixir**: For managing parallel processing using Supervisor and Worker.

### Python Libraries
- **spaCy**: For advanced NLP tasks like NER and part-of-speech tagging.
- **transformers**: Leveraging pre-trained models like BERT or GPT.
- **VADER**: Sentiment analysis.
- **Pillow (PIL)**: Image processing.
- **pytesseract**: OCR for extracting text from images.
- **fitz (PyMuPDF)**: PDF text extraction.
- **python-pptx**: Parsing PowerPoint files.
- **pandas**: Data manipulation and analysis.
- **sqlite3**: Lightweight database for initial data handling.
- **python-docx**: Processing Microsoft Word documents.
- **python-magic**: File type detection.

### Elixir Libraries & Tools
- **Ecto**: Database integration and query handling.
- **GenServer**: For creating Workers.
- **System.cmd**: Executing shell commands.
- **Supervisor**: Manages and monitors Worker processes.

### Database
- **PostgreSQL**: Centralized storage for processed data.

---

## Architecture

### Parallel Processing with Supervisor-Worker Model
The application employs **Elixir's Supervisor-Worker model** to manage tasks:
1. **Supervisor**: Ensures that Worker processes are monitored and restarted if they fail.
2. **Workers**: Execute specific tasks in parallel, such as text analysis, document parsing, or data storage.

This architecture ensures:
- **High Performance**: Tasks are processed in parallel, reducing overall execution time.
- **Automatic Task Recovery**: Pending tasks are automatically restarted by the Supervisor in case of failure.

---

## Setup Instructions

### Prerequisites
- Python 3.11 or higher
- Elixir 1.17 or higher
- PostgreSQL

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/febrd/CodeClauseInternship_ARTLED_Artificial_Legal_Documents.git
   cd CodeClauseInternship_ARTLED_Artificial_Legal_Documents
   ```

2. Set up PostgreSQL:
   - Create a database:
     ```bash
     createdb nlp_project
     ```
   - Update connection details in the configuration file.

3. Initialize the project:
   ```bash
   chmod +x INSTALL/init.sh
   ./INSTALL/init.sh
   ```

4. Start the application:
   ```bash
   iex -S mix phx.server
   ```

---

## Usage
1. Open your browser and visit:  
   [http://localhost:4000](http://localhost:4000)

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.
