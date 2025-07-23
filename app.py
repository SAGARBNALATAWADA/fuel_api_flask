from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np

app = Flask(__name__)
CORS(app)

# Load model and scaler
model = pickle.load(open("model_assets/trained_model_lr.sav", "rb"))
scaler = pickle.load(open("model_assets/scaled_data.sav", "rb"))

@app.route('/predict', methods=['POST'])
def api_predict():
    try:
        data = request.get_json()
        print("[DEBUG] Received data:", data)

        # Updated full mappings to match Flutter dropdowns
        vehicle_types = {
            'Compact': 0, 'SUV': 1, 'Sedan': 2, 'Hatchback': 3,
            'Pickup': 4, 'Minivan': 5, 'Station Wagon': 6,
            'Convertible': 7, 'Coupe': 8, 'Other': 9
        }

        trans_types = {
            'AM': 0,  # Automated Manual
            'AS': 1,  # Auto with Select Shift
            'AV': 2,  # Continuously Variable
            'M': 3,   # Manual
            'A': 4    # Automatic
        }

        fuel_types = {
            'X': 0,  # Regular gasoline
            'Z': 1,  # Premium gasoline
            'D': 2,  # Diesel
            'E': 3,  # Ethanol (E85)
        }

        # Get encoded values or -1 if not found
        vehicle = vehicle_types.get(data['vehicle'], -1)
        trans = trans_types.get(data['trans'], -1)
        fuel = fuel_types.get(data['fuel'], -1)

        engine = float(data['engine'])
        cyl = int(data['cyl'])
        co2 = float(data['co2'])

        print("[DEBUG] Encoded values:", vehicle, trans, fuel)

        if -1 in [vehicle, trans, fuel]:
            return jsonify({'error': 'Invalid input values'}), 400

        # Add 3 placeholder values to match scaler's expected 9 features
        # Replace 2020, 0, 0 with realistic values if known
        input_array = np.array([[vehicle, engine, cyl, trans, co2, fuel, 2020, 0, 0]])

        print("[DEBUG] Input array before scaling:", input_array)

        input_scaled = scaler.transform(input_array)
        print("[DEBUG] Scaled input:", input_scaled)

        prediction = model.predict(input_scaled)
        print("[DEBUG] Prediction:", prediction)

        return jsonify({'prediction': round(float(prediction[0]), 2)})

    except Exception as e:
        print("[ERROR]", e)
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
