from locust import HttpUser, task, between
import random

class ProductAPIUser(HttpUser):
    """
    Simple test that focuses on products we know exist (1-20)
    """
    wait_time = between(1, 3)
    
    @task(8)  # 80% - Read operations
    def get_product(self):
        """Get products 1-20 (we created these)"""
        product_id = random.randint(1, 20)
        
        with self.client.get(
            f"/products/{product_id}",
            catch_response=True,
            name="/products/[id]"
        ) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Expected 200, got {response.status_code}")
    
    @task(2)  # 20% - Write operations
    def create_or_update_product(self):
        """Create/update products"""
        product_id = random.randint(1, 100)
        product_data = {
            "product_id": product_id,
            "sku": f"SKU-{product_id:05d}",
            "manufacturer": f"Manufacturer-{random.randint(1, 20)}",
            "category_id": random.randint(1, 50),
            "weight": random.randint(100, 5000),
            "some_other_id": random.randint(1000, 9999)
        }
        
        with self.client.post(
            f"/products/{product_id}/details",
            json=product_data,
            catch_response=True,
            name="/products/[id]/details"
        ) as response:
            if response.status_code == 204:
                response.success()
            else:
                response.failure(f"Expected 204, got {response.status_code}")