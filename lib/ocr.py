
import fitz  # PyMuPDF
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/pdf-reader', methods=['POST'])
def pdf_reader():
    file = request.files['file']
    if file:
        # Dosyayı kaydetmek yerine, doğrudan hafızada işle
        file_stream = file.stream
        pdf = fitz.open("pdf", file_stream.read())
        text = ""
        for page in pdf:
            text += page.get_text()
        pdf.close()
        return jsonify({'text': text})

if __name__ == '__main__':
    app.run(debug=True)
