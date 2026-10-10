import os
import socket
from urllib.parse import urlparse

import pytest

from fixture_app import add


def test_add_sums_two_numbers():
    assert add(2, 3) == 5


@pytest.mark.skipif(
    "DATABASE_URL" not in os.environ, reason="needs the PostgreSQL service container"
)
def test_postgres_service_is_reachable():
    url = urlparse(os.environ["DATABASE_URL"])
    with socket.create_connection((url.hostname, url.port), timeout=5):
        pass
