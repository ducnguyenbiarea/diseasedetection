from flask import Flask, request, jsonify, render_template
from transformers import AutoImageProcessor, AutoModelForImageClassification
from flask_cors import CORS
import torch
from PIL import Image

# Initialize app
app = Flask(__name__)
CORS(app)  # Optional if running HTML separately

# Load Hugging Face model
model_name = "wellCh4n/tomato-leaf-disease-classification-resnet50"
processor = AutoImageProcessor.from_pretrained(model_name)
model = AutoModelForImageClassification.from_pretrained(model_name)
model.eval()

# Mapping from model index to label
model_index_to_label = {
    0: "A healthy tomato leaf",
    1: "A tomato leaf with Leaf Mold",
    2: "A tomato leaf with Target Spot",
    3: "A tomato leaf with Late Blight",
    4: "A tomato leaf with Early Blight",
    5: "A tomato leaf with Bacterial Spot",
    6: "A tomato leaf with Septoria Leaf Spot",
    7: "A tomato leaf with Tomato Mosaic Virus",
    8: "A tomato leaf with Tomato Yellow Leaf Curl Virus",
    9: "A tomato leaf with Spider Mites Two-spotted Spider Mite"
}

# Your mobile app labels in correct order
mobile_labels = [
    "Tomato___Bacterial_spot",
    "Tomato___Early_blight",
    "Tomato___healthy",
    "Tomato___Late_blight",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites Two-spotted_spider_mite",
    "Tomato___Target_Spot",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus"
]

# Mapping from model index to your mobile app index
model_to_mobile_index = {
    0: 2,
    1: 4,
    2: 7,
    3: 3,
    4: 1,
    5: 0,
    6: 5,
    7: 8,
    8: 9,
    9: 6
}



@app.route("/")
def home():
    return render_template("index.html")

@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files["image"]
    image = Image.open(file.stream).convert("RGB")

    # Preprocess and predict
    inputs = processor(images=image, return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        model_index = torch.argmax(logits, dim=1).item()

    # Convert to mobile index and label
    mobile_index = model_to_mobile_index[model_index]
    mobile_label = mobile_labels[mobile_index]

    # Send back mobile-friendly output
    return jsonify({
        "index": mobile_index,
        "label": mobile_label
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)