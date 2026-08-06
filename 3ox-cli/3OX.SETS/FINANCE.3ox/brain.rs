// 3OX Finance Agent Brain
// Core intelligence module for financial analysis

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
pub struct MarketData {
    pub symbol: String,
    pub price: f64,
    pub volume: u64,
    pub timestamp: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AnalysisResult {
    pub symbol: String,
    pub trend: String,
    pub confidence: f64,
    pub recommendation: String,
}

pub struct FinanceBrain {
    market_data: HashMap<String, MarketData>,
    analysis_history: Vec<AnalysisResult>,
}

impl FinanceBrain {
    pub fn new() -> Self {
        Self {
            market_data: HashMap::new(),
            analysis_history: Vec::new(),
        }
    }

    pub fn analyze_market(&mut self, symbols: Vec<String>) -> Vec<AnalysisResult> {
        let mut results = Vec::new();
        
        for symbol in symbols {
            let result = AnalysisResult {
                symbol: symbol.clone(),
                trend: "bullish".to_string(),
                confidence: 0.85,
                recommendation: "buy".to_string(),
            };
            results.push(result);
        }
        
        self.analysis_history.extend(results.clone());
        results
    }

    pub fn assess_risk(&self, portfolio: &HashMap<String, f64>) -> f64 {
        // Simple risk calculation
        let total_weight: f64 = portfolio.values().sum();
        if total_weight == 0.0 {
            return 0.0;
        }
        
        // Calculate weighted risk (simplified)
        let mut risk = 0.0;
        for (symbol, weight) in portfolio {
            let base_risk = if symbol.len() > 3 { 0.3 } else { 0.2 };
            risk += base_risk * weight;
        }
        
        risk / total_weight
    }
}