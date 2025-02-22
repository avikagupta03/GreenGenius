import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> classifyPost(String postText) async {
  // Your Hugging Face token
  const String token = 'YOUR_HUGGINGFACE_TOKEN';

  // API URL for Hugging Face Model
  final String apiUrl = 'https://api-inference.huggingface.co/models/facebook/bart-large-mnli';

  // Send POST request to Hugging Face API
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': postText,
      'parameters': {
        'candidate_labels': ['SDG-related', 'Not SDG-related'],
      },
    }),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);

    // Parse the result to get confidence score for "SDG-related" vs "Not SDG-related"
    double sdgConfidence = result[0]['scores'][0]; // Confidence for "SDG-related"
    double notSdgConfidence = result[0]['scores'][1]; // Confidence for "Not SDG-related"

    // Example: If "Not SDG-related" has a high confidence, reject the post
    if (notSdgConfidence > 0.7) {
      print("Post is not SDG-related.");
      // Handle rejecting the post
    } else {
      print("Post is SDG-related.");
      // Handle accepting the post
    }
  } else {
    print('Error: ${response.statusCode}');
  }
}

void main() {
  String postText = "Your post text here";  // Replace with the text to classify
  classifyPost(postText);
}
