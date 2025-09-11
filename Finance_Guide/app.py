# app.py (updated)
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Load structured scholarships CSV
df = pd.read_csv("scholarships_structured.csv")

@app.route("/get_scholarships", methods=["POST"])
def get_scholarships():
    try:
        data = request.json
        
        field = data.get("field", "")
        level = data.get("level", "")
        category = data.get("category", "")
        region = data.get("region", "")

        # Filter scholarships
        filtered_df = df.copy()
        
        if field:
            filtered_df = filtered_df[filtered_df['eligibility'].str.contains(field, case=False, na=False)]
        if level:
            filtered_df = filtered_df[filtered_df['eligibility'].str.contains(level, case=False, na=False)]
        if category:
            filtered_df = filtered_df[filtered_df['category'].str.contains(category, case=False, na=False)]
        if region:
            filtered_df = filtered_df[filtered_df['region'].str.contains(region, case=False, na=False)]

        top_3 = filtered_df.head(3)

        # Convert to list of dictionaries for JSON
        result = top_3.to_dict(orient="records")
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)