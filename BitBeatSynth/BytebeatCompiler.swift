import JavaScriptCore

struct BytebeatCompiler {
    static let context: JSContext = {
        let ctx = JSContext()!
        ctx.exceptionHandler = { ctx, err in
            print("JS Error: \(err?.toString() ?? "unknown")")
        }
        return ctx
    }()

    static func compile(expression: String, engine: BytebeatAudioEngine) -> ((UInt32) -> UInt8, String?) {
        let ctx = JSContext()!
        var latestError: String? = nil

        ctx.exceptionHandler = { _, error in
            latestError = error?.toString()
            print("JS Error: \(latestError ?? "unknown")")
        }

        let expr = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        let wrappedExpr = "(\(expr)) & 255"

        ctx.setObject(engine.variableX, forKeyedSubscript: "x" as NSString)
        ctx.setObject(engine.variableY, forKeyedSubscript: "y" as NSString)
        ctx.evaluateScript("function f(t) { return \(wrappedExpr); }")

        guard let fn = ctx.objectForKeyedSubscript("f"), fn.isObject else {
            return ({ _ in UInt8(0) }, latestError ?? "Expression did not compile.")
        }

        let compiled: (UInt32) -> UInt8 = { t in
            ctx.setObject(engine.variableX, forKeyedSubscript: "x" as NSString)
            ctx.setObject(engine.variableY, forKeyedSubscript: "y" as NSString)
            ctx.setObject(engine.variableA, forKeyedSubscript: "a" as NSString)
            ctx.setObject(engine.variableB, forKeyedSubscript: "b" as NSString)
            let result = fn.call(withArguments: [t])?.toInt32() ?? 0
            return UInt8(clamping: result)
        }

        return (compiled, latestError)
    }




    private static func needsMasking(_ expr: String) -> Bool {
        // basic check to avoid double-masking
        return !expr.contains("&") && !expr.contains("%")
    }
}

