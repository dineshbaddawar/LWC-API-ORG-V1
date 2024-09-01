// Apex class to make Google My Business API request
public class GoogleReviewAPI {
    
    // Replace these constants with your actual values
    private static final String API_ENDPOINT = 'https://mybusiness.googleapis.com/v4/accounts/YOUR_ACCOUNT_ID/locations/YOUR_LOCATION_ID/reviews';
    private static final String ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN';
    
    // Method to make the API request
    public static void getReviews() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_ENDPOINT);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        
        // Create an HTTP object to send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Process the response
        if (response.getStatusCode() == 200) {
            // Successfully retrieved reviews, process the response body
            String responseBody = response.getBody();
            
            // Process the responseBody as needed
            System.debug(responseBody);
        } else {
            // Handle the error response
            System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
        }
    }
}