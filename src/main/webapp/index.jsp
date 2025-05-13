<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,org.apache.commons.text.StringEscapeUtils" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cloud247 ChatBot</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        pre {
            background-color: #0f172a;
            color: #f1f5f9;
            padding: 1rem;
            border-radius: 0.5rem;
            overflow-x: auto;
            margin-top: 0.5rem;
            font-size: 0.875rem;
            position: relative;
            line-height: 1.4;
        }
        .copy-btn {
            position: absolute;
            top: 8px;
            right: 12px;
            background-color: #1e40af;
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            cursor: pointer;
        }
        .toast {
    position: absolute;
    top: 5rem; /* slightly below header */
    right: 2rem; /* inside chat panel, not screen edge */
    background: #2563eb;
    color: white;
    padding: 0.75rem 1.25rem;
    border-radius: 0.375rem;
    box-shadow: 0 2px 6px rgba(0,0,0,0.15);
    display: none;
    z-index: 10;
}

    </style>
</head>
<body class="bg-gray-100 h-screen flex overflow-hidden text-gray-800">

    <!-- Sidebar -->
    <aside class="w-64 bg-white shadow-md p-5 flex flex-col gap-4">
        <h2 class="text-xl font-bold mb-4">⚙️ Actions</h2>

        <form action="ChatServlet" method="get">
            <button name="clear" value="true" type="submit" class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 text-sm w-full">
                🗑️ New Chat
            </button>
        </form>

        <button onclick="toggleTheme()" class="bg-yellow-500 text-white px-4 py-2 rounded hover:bg-yellow-600 text-sm w-full">
            🌗 Toggle Theme
        </button>

        <button onclick="showInfo()" class="bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-800 text-sm w-full">
            ℹ️ About Bot
        </button>

        <div class="mt-4 text-sm">
            <p class="font-semibold mb-2">Quick Prompts:</p>
            <button onclick="insertPrompt('Explain REST API with example')" class="text-blue-600 hover:underline block mb-1">💡 Explain REST API</button>
            <button onclick="insertPrompt('Write Java code for Bubble Sort')" class="text-blue-600 hover:underline block mb-1">🧠 Bubble Sort (Java)</button>
        </div>
    </aside>

    <!-- Chat Panel -->
    <div class="flex-1 flex flex-col h-full">

        <!-- Header -->
        <header class="bg-blue-700 text-white py-4 text-center shadow-md">
            <h1 class="text-2xl font-semibold">🤖 Cloud247 ChatBot</h1>
        </header>
        
        <!-- Toast -->
    <div id="toast" class="toast">Notification</div>

        <!-- Chat Window -->
        <main class="flex-1 overflow-y-auto px-6 py-6" id="chatArea">
            <div class="max-w-3xl mx-auto space-y-6">
            <%
                HttpSession sessionObj = request.getSession();
                List<Map<String, String>> history = (List<Map<String, String>>) sessionObj.getAttribute("chatHistory");

                if (history != null) {
                    for (Map<String, String> chat : history) {
                        String user = StringEscapeUtils.escapeHtml4(chat.get("user"));
                        String ai = StringEscapeUtils.escapeHtml4(chat.get("ai"));
                        ai = ai.replaceAll("(?s)```(.*?)```", "<pre><button class='copy-btn' onclick='copyCode(this)'>Copy</button><code>$1</code></pre>");
            %>
            <!-- User Message -->
            <div class="flex justify-end">
                <div class="bg-blue-600 text-white px-4 py-2 rounded-md max-w-[75%] text-sm shadow-sm min-w-[64px] min-h-[40px] flex items-center justify-center">
                    <%= user %>
                </div>
            </div>

            <!-- AI Response -->
            <div class="flex justify-start">
                <div class="bg-white border border-gray-300 px-5 py-4 rounded-2xl max-w-[85%] text-gray-800 text-sm shadow whitespace-pre-line leading-relaxed">
                    <strong class="text-gray-700 block mb-1">AI:</strong>
                    <%= ai %>
                </div>
            </div>
            <%
                    }
                }
            %>
            </div>
        </main>

        <!-- Input -->
        <footer class="bg-white shadow-md p-4">
            <form action="ChatServlet" method="post" class="max-w-3xl mx-auto flex gap-2 items-center" onsubmit="showLoader()">
                <textarea name="message" rows="2" placeholder="Ask me anything..." required
                    class="flex-1 p-3 border border-gray-300 rounded-md focus:outline-none resize-none text-sm shadow"></textarea>
                <button type="submit"
                    class="bg-blue-600 text-white px-5 py-2 rounded-md hover:bg-blue-700 shadow flex items-center gap-2">
                    <span id="btnText">Send</span>
                    <span id="loader" class="hidden animate-spin rounded-full h-4 w-4 border-t-2 border-white"></span>
                </button>
            </form>
        </footer>
    </div>

    

    <script>
        window.onload = () => {
            const chat = document.getElementById("chatArea");
            chat.scrollTop = chat.scrollHeight;
        };

        function showLoader() {
            document.getElementById("btnText").textContent = "Sending";
            document.getElementById("loader").classList.remove("hidden");
        }

        function copyCode(button) {
            const code = button.nextElementSibling?.textContent || '';
            navigator.clipboard.writeText(code).then(() => {
                showToast("Copied to clipboard!");
            });
        }

        function showToast(message) {
            const toast = document.getElementById("toast");
            toast.textContent = message;
            toast.style.display = "block";
            setTimeout(() => toast.style.display = "none", 2000);
        }

        function showInfo() {
            showToast("🤖 Cloud247 Bot: An intelligent assistant built to help you code, learn, and explore topics!");
        }

        function insertPrompt(text) {
            document.querySelector("textarea[name='message']").value = text;
        }

        function toggleTheme() {
            document.body.classList.toggle("bg-gray-900");
            document.body.classList.toggle("text-white");
            showToast("Theme toggled!");
        }
    </script>
</body>
</html>
