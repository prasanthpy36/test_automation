import requests


def test_user_service():
    # Make an HTTP request to the user service
    response = requests.get("http://localhost:30080/users/1")

    # Check the status code
    assert response.status_code == 200

    # Read the response body
    body = response.json()

    # Assert the response body
    expected_body = {"id": 1, "name": "Alice", "Product": {"id": 1, "name": "Laptop", "price": 1000}}
    assert body == expected_body
