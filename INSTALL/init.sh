
# ARTIFICIAL SETUP
pip install -r INSTALL/requirements.txt
python -m spacy download en_core_web_sm
   
#PROJECT SETUP
mix deps.get

## ECTO
mix ecto.setup
iex -S mix phx.server