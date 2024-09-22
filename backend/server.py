import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import google.generativeai as genai
from PIL import Image
from flask_cors import CORS
from dotenv import load_dotenv
from supabase import create_client, Client
import requests
from io import BytesIO

load_dotenv()

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

api_key = os.getenv('API_KEY')
genai.configure(api_key=api_key)
model = genai.GenerativeModel('gemini-1.5-flash')

# Supabase setup
supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
supabase: Client = create_client(supabase_url, supabase_key)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


def analyze_image_with_gemini(image_path):
    img = Image.open(image_path)
    response = model.generate_content([
        "You have been given an image with some mathematical expressions, equations, or graphical problems, and you need to solve them. "
        "Note: Use the PEMDAS rule for solving mathematical expressions. PEMDAS stands for the Priority Order: Parentheses, Exponents, Multiplication and Division (from left to right), Addition and Subtraction (from left to right). Parentheses have the highest priority, followed by Exponents, then Multiplication and Division, and lastly Addition and Subtraction. "
        "For example: "
        "Q. 2 + 3 * 4 "
        "(3 * 4) => 12, 2 + 12 = 14. "
        "Q. 2 + 3 + 5 * 4 - 8 / 2 "
        "5 * 4 => 20, 8 / 2 => 4, 2 + 3 => 5, 5 + 20 => 25, 25 - 4 => 21. "
        "YOU CAN HAVE FIVE TYPES OF EQUATIONS/EXPRESSIONS IN THIS IMAGE, AND ONLY ONE CASE SHALL APPLY EVERY TIME: "
        "Following are the cases: "
        "1. Simple mathematical expressions like 2 + 2, 3 * 4, 5 / 6, 7 - 8, etc.: In this case, solve and return the answer in the format of a LIST OF ONE DICT [{{'expr': given expression, 'result': calculated answer}}]. "
        "2. Set of Equations like x^2 + 2x + 1 = 0, 3y + 4x = 0, 5x^2 + 6y + 7 = 12, etc.: In this case, solve for the given variable, and the format should be a COMMA SEPARATED LIST OF DICTS, with dict 1 as {{'expr': 'x', 'result': 2, 'assign': True}} and dict 2 as {{'expr': 'y', 'result': 5, 'assign': True}}. This example assumes x was calculated as 2, and y as 5. Include as many dicts as there are variables. "
        "3. Assigning values to variables like x = 4, y = 5, z = 6, etc.: In this case, assign values to variables and return another key in the dict called {{'assign': True}}, keeping the variable as 'expr' and the value as 'result' in the original dictionary. RETURN AS A LIST OF DICTS. "
        "4. Analyzing Graphical Math problems, which are word problems represented in drawing form, such as cars colliding, trigonometric problems, problems on the Pythagorean theorem, adding runs from a cricket wagon wheel, etc. These will have a drawing representing some scenario and accompanying information with the image. PAY CLOSE ATTENTION TO DIFFERENT COLORS FOR THESE PROBLEMS. You need to return the answer in the format of a LIST OF ONE DICT [{{'expr': given expression, 'result': calculated answer}}]. "
        "5. Detecting Abstract Concepts that a drawing might show, such as love, hate, jealousy, patriotism, or a historic reference to war, invention, discovery, quote, etc. USE THE SAME FORMAT AS OTHERS TO RETURN THE ANSWER, where 'expr' will be the explanation of the drawing, and 'result' will be the abstract concept. "
        "Analyze the equation or expression in this image and return the answer according to the given rules: "
        "Make sure to use extra backslashes for escape characters like \\f -> \\\\f, \\n -> \\\\n, etc. "
        "Here is a dictionary of user-assigned variables. If the given expression has any of these variables, use its actual value from this dictionary accordingly: {dict_of_vars_str}. "
        "DO NOT USE BACKTICKS OR MARKDOWN FORMATTING. "
        "PROPERLY QUOTE THE KEYS AND VALUES IN THE DICTIONARY FOR EASIER PARSING WITH Python's ast.literal_eval.",
        img
    ])
    print(response.text)
    return response.text


@app.route('/process_image', methods=['POST'])
def process_image():
    data = request.json
    image_id = data.get('image_id')
    image_url = data.get('image_url')

    if not image_id or not image_url:
        return jsonify({'error': 'Missing image_id or image_url'}), 400

    try:
        # Download the image from Supabase
        response = requests.get(image_url)
        if response.status_code != 200:
            return jsonify({'error': 'Failed to download image from Supabase'}), 500

        # Save the image temporarily
        temp_image_path = os.path.join(
            app.config['UPLOAD_FOLDER'], f"{image_id}.png")
        with open(temp_image_path, 'wb') as f:
            f.write(response.content)

        # Analyze the image
        analysis_result = analyze_image_with_gemini(temp_image_path)

        # Clean up the temporary file
        os.remove(temp_image_path)

        # Send the analysis result to the client
        return jsonify({
            'message': 'Image processed successfully',
            'analysis': analysis_result
        }), 200

    except Exception as e:
        return jsonify({'error': f'Error processing image: {str(e)}'}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
