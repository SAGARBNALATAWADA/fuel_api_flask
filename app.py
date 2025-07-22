from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np

app = Flask(__name__)
CORS(app)

# Load model and scaler
model = pickle.load(open("model_assets/trained_model_lr.sav", "rb"))
scaler = pickle.load(open("model_assets/scaled_data.sav", "rb"))

@app.route('/api/predict', methods=['POST'])
def api_predict():
    try:
        data = request.get_json()
        print("[DEBUG] Received data:", data)

        vehicle_types = {'Sedan': 0, 'SUV': 1, 'Hatchback': 2}
        trans_types = {'Auto': 0, 'Manual': 1}
        fuel_types = {'Petrol': 0, 'Diesel': 1, 'CNG': 2}

        vehicle = vehicle_types.get(data['vehicle'], -1)
        engine = float(data['engine'])
        cyl = int(data['cyl'])
        trans = trans_types.get(data['trans'], -1)
        co2 = float(data['co2'])
        fuel = fuel_types.get(data['fuel'], -1)

        if -1 in [vehicle, trans, fuel]:
            return jsonify({'error': 'Invalid input values'}), 400

        input_data = np.array([[vehicle, engine, cyl, trans, co2, fuel]])
        print("[DEBUG] Input array before scaling:", input_data)

        input_scaled = scaler.transform(input_data)
        print("[DEBUG] Scaled input:", input_scaled)

        prediction = model.predict(input_scaled)
        print("[DEBUG] Prediction:", prediction)

        return jsonify({'prediction': round(float(prediction[0]), 2)})

    except Exception as e:
        print("[ERROR] Prediction failed:", str(e))
        return jsonify({'error': 'Prediction failed'})



if __name__ == '__main__':
    app.run(debug=True)
