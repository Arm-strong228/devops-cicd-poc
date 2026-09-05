package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HelloController {

    private final CalculatorService calculatorService = new CalculatorService();

    @GetMapping("/api/hello")
    public Map<String, String> hello() {
        return Map.of(
                "message", "Bonjour depuis le pipeline CI/CD Jenkins !",
                "status", "ok"
        );
    }

    @GetMapping("/api/add")
    public Map<String, Integer> add(@RequestParam int a, @RequestParam int b) {
        return Map.of("result", calculatorService.add(a, b));
    }
}
