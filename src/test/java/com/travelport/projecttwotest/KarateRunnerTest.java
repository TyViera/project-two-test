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

  @Karate.Test()
  Karate karateTests() {
    return Karate.run("./target/test-classes/features")
        .systemProperty("karate.host", remoteServerHost)
        .systemProperty("karate.port", remoteServerPort)
        .tags(List.of("~@ignore"));
  }
}
