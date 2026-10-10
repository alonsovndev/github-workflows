package fixture;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;
import org.junit.jupiter.api.Test;

/** Proves the PostgreSQL service container is reachable through the exported POSTGRES_* variables. */
class DatabaseEnvironmentTest {

  @Test
  void reachesThePostgresServiceWhenOneIsConfigured() throws IOException {
    String host = System.getenv("POSTGRES_HOST");
    assumeTrue(host != null && !host.isBlank(), "No PostgreSQL service configured");

    try (Socket socket = new Socket()) {
      socket.connect(new InetSocketAddress(host, Integer.parseInt(System.getenv("POSTGRES_PORT"))), 3000);
      assertTrue(socket.isConnected());
    }
  }
}
