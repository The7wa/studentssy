package com.sms.util;

import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * 极简 CSV 读写工具（不依赖 POI，导出的 CSV 带 UTF-8 BOM，Excel 可直接打开）。
 */
public final class CsvUtil {

    private CsvUtil() {
    }

    /**
     * 输出 CSV 下载。每行是一个 String 数组，字段会自动转义。
     */
    public static void write(HttpServletResponse response, String filename,
                             String[] header, List<String[]> rows) throws IOException {
        String encoded = URLEncoder.encode(filename, "UTF-8").replace("+", "%20");
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + encoded + "\"; filename*=UTF-8''" + encoded);
        response.setCharacterEncoding("UTF-8");

        OutputStream out = response.getOutputStream();
        out.write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        try (PrintWriter writer = new PrintWriter(new OutputStreamWriter(out, StandardCharsets.UTF_8))) {
            writeRow(writer, header);
            if (rows != null) {
                for (String[] row : rows) {
                    writeRow(writer, row);
                }
            }
            writer.flush();
        }
    }

    private static void writeRow(PrintWriter writer, String[] values) {
        if (values == null) {
            writer.println();
            return;
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < values.length; i++) {
            if (i > 0) {
                sb.append(',');
            }
            sb.append(escape(values[i]));
        }
        writer.println(sb.toString());
    }

    public static String escape(String value) {
        if (value == null) {
            return "";
        }
        boolean needQuote = value.indexOf(',') >= 0 || value.indexOf('"') >= 0
                || value.indexOf('\n') >= 0 || value.indexOf('\r') >= 0;
        if (!needQuote) {
            return value;
        }
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }

    /**
     * 读取 CSV（支持引号转义，忽略空行）。返回的每一行是字段列表。
     */
    public static List<String[]> read(InputStream in) throws IOException {
        List<String[]> rows = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String line;
            boolean first = true;
            while ((line = reader.readLine()) != null) {
                if (first) {
                    first = false;
                    if (!line.isEmpty() && line.charAt(0) == '\uFEFF') {
                        line = line.substring(1);
                    }
                }
                if (line.trim().isEmpty()) {
                    continue;
                }
                rows.add(parseLine(line).toArray(new String[0]));
            }
        }
        return rows;
    }

    static List<String> parseLine(String line) {
        List<String> values = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        boolean inQuotes = false;
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (inQuotes) {
                if (c == '"') {
                    if (i + 1 < line.length() && line.charAt(i + 1) == '"') {
                        sb.append('"');
                        i++;
                    } else {
                        inQuotes = false;
                    }
                } else {
                    sb.append(c);
                }
            } else if (c == '"') {
                inQuotes = true;
            } else if (c == ',') {
                values.add(sb.toString().trim());
                sb.setLength(0);
            } else {
                sb.append(c);
            }
        }
        values.add(sb.toString().trim());
        return values;
    }
}
