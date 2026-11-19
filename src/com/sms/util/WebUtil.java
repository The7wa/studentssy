package com.sms.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Web 层小工具。
 */
public final class WebUtil {

    private WebUtil() {
    }

    public static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static int intValue(String value, int defaultValue) {
        try {
            return Integer.parseInt(trim(value));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static Integer intOrNull(String value) {
        String text = trim(value);
        if (text.isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(text);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static double doubleValue(String value, double defaultValue) {
        try {
            return Double.parseDouble(trim(value));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** 只在 1-5 之间取页码，防止乱传参数。 */
    public static int page(String value) {
        int page = intValue(value, 1);
        return page < 1 ? 1 : page;
    }

    public static void flash(HttpServletRequest request, String type, String message) {
        Map<String, String> flash = new LinkedHashMap<>();
        flash.put("type", type);
        flash.put("message", message);
        request.getSession().setAttribute("flash", flash);
    }

    public static void redirect(HttpServletRequest request, HttpServletResponse response, String path)
            throws IOException {
        response.sendRedirect(request.getContextPath() + path);
    }

    public static String greeting() {
        int hour = LocalTime.now().getHour();
        if (hour < 6) {
            return "夜深了";
        }
        if (hour < 12) {
            return "早上好";
        }
        if (hour < 14) {
            return "中午好";
        }
        if (hour < 18) {
            return "下午好";
        }
        return "晚上好";
    }

    /** 把文本转成 HTML 属性 / JS 字符串安全的形式，用于非 JSTL 输出场景。 */
    public static String attr(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("'", "&#39;");
    }

    /** 去掉空白后为空的字符串返回 null，便于数据库存 NULL。 */
    public static String nullIfBlank(String value) {
        String text = trim(value);
        return text.isEmpty() ? null : text;
    }
}
