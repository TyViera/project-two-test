package com.travelport.projecttwotest;

import com.intuit.karate.junit5.Karate;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(classes = ProjectTwoTestApplication.class)
public class KarateRunnerTest {

  @Value("${karate.host:http://localhost}")
  private String remoteServerHost;

  @Value("${karate.port:8080}")
  private String remoteServerPort;

  @Value("${karate.auth.user:admin}")
  private String authUser;

  @Value("${karate.auth.pass:admin}")
  private String authPassword;

  @Value("${karate.stock:false}")
  private boolean runStock;

  @Karate.Test()
  Karate karateTests() {
    var tags = runStock ? List.of("~@ignore") : List.of("~@ignore", "~@stock");
    return Karate.run("./target/test-classes/features")
        .systemProperty("karate.host", remoteServerHost)
        .systemProperty("karate.port", remoteServerPort)
        .systemProperty("karate.auth.user", authUser)
        .systemProperty("karate.auth.pass", authPassword)
        .tags(tags);
  }
}
