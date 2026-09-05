package com.example.demo;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CalculatorServiceTest {

    private final CalculatorService calculator = new CalculatorService();

    @Test
    void addShouldReturnSum() {
        assertEquals(5, calculator.add(2, 3));
    }

    @Test
    void subtractShouldReturnDifference() {
        assertEquals(1, calculator.subtract(3, 2));
    }

    @Test
    void divideShouldReturnQuotient() {
        assertEquals(2, calculator.divide(10, 5));
    }

    @Test
    void divideByZeroShouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> calculator.divide(10, 0));
    }
}
