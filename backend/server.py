import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import google.generativeai as genai
from PIL import Image

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

genai.configure(api_key='API_KEYS')
model = genai.GenerativeModel('gemini-1.5-flash')

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def analyze_image_with_gemini(image_path):
    img = Image.open(image_path)
    response = model.generate_content([
        "Analyze this image. If there are any mathematical equations, solve them step by step. "
        "Then provide a brief summary of the content, including the equations and their solutions.",
        img
    ])
    print(response.text) 

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'image' not in request.files:
        return jsonify({'error': 'No file part in the request'}), 400
    
    file = request.files['image']
    
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        try:
            analysis_result = analyze_image_with_gemini(file_path)
            
            return jsonify({
                'message': 'File uploaded and analyzed successfully',
                'path': file_path,
                'analysis': analysis_result
            }), 200
        except Exception as e:
            return jsonify({'error': f'Error analyzing image: {str(e)}'}), 500
    
    return jsonify({'error': 'File type not allowed'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

