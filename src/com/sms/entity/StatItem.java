package com.sms.entity;

/**
 * 图表用的简单统计项：标签 + 数值（可选附加百分比）。
 */
public class StatItem {

    private final String label;
    private final int value;
    private final double percent;

    public StatItem(String label, int value, double percent) {
        this.label = label;
        this.value = value;
        this.percent = percent;
    }

    public String getLabel() {
        return label;
    }

    public int getValue() {
        return value;
    }

    public double getPercent() {
        return percent;
    }
}
