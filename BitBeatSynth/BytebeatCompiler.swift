import JavaScriptCore

struct BytebeatCompiler {
    static let context: JSContext = {
        let ctx = JSContext()!
        ctx.exceptionHandler = { ctx, err in
            print("JS Error: \(err?.toString() ?? "unknown")")
        }
        return ctx
    }()

    static func compile(expression: String) -> (UInt32) -> UInt8 {
        let sanitized = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        let wrapped = needsMasking(sanitized) ? "(\(sanitized)) & 255" : sanitized

        let jsCode = "function f(t) { return \(wrapped); }"
        context.evaluateScript(jsCode)

        let fn = context.objectForKeyedSubscript("f")
        return { t in
            let result = fn?.call(withArguments: [t]).toInt32() ?? 0
            return UInt8(clamping: result)
        }
    }

    private static func needsMasking(_ expr: String) -> Bool {
        // basic check to avoid double-masking
        return !expr.contains("&") && !expr.contains("%")
    }
}

