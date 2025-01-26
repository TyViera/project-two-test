package com.travelport.projecttwotest;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.intuit.karate.junit5.Karate;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;
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

  @Value("${karate.auth.crud:false}")
  private boolean authInCrudOperations;

  @Value("${karate.stock:false}")
  private boolean runStock;

  @Test
  void karateTests() {
    var tags = new ArrayList<String>(2);
    tags.add("~@ignore");
    if (!runStock) {
      tags.add("~@stock");
    }
    var results =
        Karate.run("classpath:features")
            .outputCucumberJson(true)
            .systemProperty("karate.host", remoteServerHost)
            .systemProperty("karate.port", remoteServerPort)
            .systemProperty("karate.auth.user", authUser)
            .systemProperty("karate.auth.pass", authPassword)
            .systemProperty("karate.auth.crud", authInCrudOperations + "")
            .tags(Collections.unmodifiableList(tags))
            .parallel(1);

    generateReport(results.getReportDir());
    assertEquals(0, results.getFailCount(), results.getErrorMessages());
  }

  private static void generateReport(String karateOutputPath) {
    var jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
    var jsonPaths = new ArrayList<String>(jsonFiles.size());
    jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
    var config = new Configuration(new File("target"), "Project two operations");
    var reportBuilder = new ReportBuilder(jsonPaths, config);
    reportBuilder.generateReports();
  }
}
