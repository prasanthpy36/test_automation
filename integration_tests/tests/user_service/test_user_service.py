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
import requests
import pytest

def test_product_service_with_invalid_id():
    # Make an HTTP request to the product service with an invalid ID
    response = requests.get("http://localhost:30081/products/invalid")

    # Check the status code
    assert response.status_code == 400, "Expected status code 400, but got {}".format(response.status_code)

def test_product_service_with_nonexistent_id():
    # Make an HTTP request to the product service with a nonexistent ID
    response = requests.get("http://localhost:30081/products/999999")

    # Check the status code
    assert response.status_code == 404, "Expected status code 404, but got {}".format(response.status_code)

def test_product_service_with_non_numeric_id():
    # Make an HTTP request to the product service with a non-numeric ID
    response = requests.get("http://localhost:30081/products/abc")

    # Check the status code
    assert response.status_code == 400, "Expected status code 400, but got {}".format(response.status_code)