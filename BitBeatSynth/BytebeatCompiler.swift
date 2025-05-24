import JavaScriptCore

struct BytebeatCompiler {
    static let context: JSContext = {
        let ctx = JSContext()!
        ctx.exceptionHandler = { ctx, err in
            print("JS Error: \(err?.toString() ?? "unknown")")
        }
        return ctx
    }()

    static func compile(expression: String, engine: BytebeatAudioEngine) -> (UInt32) -> UInt8 {
        let ctx = JSContext()!
        ctx.exceptionHandler = { ctx, err in
            print("JS Error: \(err?.toString() ?? "unknown")")
        }

        let expr = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        let wrappedExpr = "(\(expr)) & 255"

        ctx.setObject(engine.variableX, forKeyedSubscript: "x" as NSString)
        ctx.setObject(engine.variableY, forKeyedSubscript: "y" as NSString)
        ctx.evaluateScript("function f(t) { return \(wrappedExpr); }")

        guard let fn = ctx.objectForKeyedSubscript("f"), fn.isObject else {
            print("⚠️ Expression failed to compile. Falling back to t & 255.")
            return { t in UInt8(t & 0xFF) }
        }

        return { t in
            ctx.setObject(engine.variableX, forKeyedSubscript: "x" as NSString)
            ctx.setObject(engine.variableY, forKeyedSubscript: "y" as NSString)
            let result = fn.call(withArguments: [t])?.toInt32() ?? 0
            return UInt8(clamping: result)
        }
    }



    private static func needsMasking(_ expr: String) -> Bool {
        // basic check to avoid double-masking
        return !expr.contains("&") && !expr.contains("%")
    }
}

