import requests

url = "http://34.228.228.162"

request_response = requests.head(url)
status_code = request_response.status_code
print(status_code)