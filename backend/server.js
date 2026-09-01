require("dotenv").config();

const express = require("express");
const cors = require("cors");

const app = express();

const PORT = process.env.PORT || 3000;
const GROQ_API_KEY = process.env.GROQ_API_KEY;

// Groq OpenAI-compatible API
const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";

// Fast and capable model suitable for MockMate
const MODEL = "openai/gpt-oss-120b";
if (!GROQ_API_KEY) {
  console.error("ERROR: GROQ_API_KEY is missing.");
  console.error("Make sure backend/.env contains GROQ_API_KEY=...");
  process.exit(1);
}

app.use(
  cors({
    origin: true,
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
  })
);

app.use(express.json());

/*
 * Root endpoint
 */
app.get("/", (req, res) => {
  res.json({
    status: "ok",
    service: "MockMate AI Backend",
  });
});

/*
 * Health endpoint
 */
app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    model: MODEL,
    provider: "Groq",
  });
});

/*
 * Common Groq request function
 */
async function askGroq(messages) {
  const response = await fetch(GROQ_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${GROQ_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: MODEL,
      messages: messages,
      temperature: 0.7,
      max_tokens: 300,
    }),
  });

  const responseText = await response.text();

  let data;

  try {
    data = JSON.parse(responseText);
  } catch (error) {
    console.error("Invalid Groq response:", responseText);

    throw new Error(
      `Invalid response from Groq (${response.status})`
    );
  }

  if (!response.ok) {
    console.error("Groq API Error:", data);

    throw new Error(
      data?.error?.message ||
        data?.message ||
        `Groq API returned status ${response.status}`
    );
  }

  const content =
    data?.choices?.[0]?.message?.content;

  if (!content || typeof content !== "string") {
    console.error("Unexpected Groq response:", data);
    throw new Error("Groq returned no usable text.");
  }

  return content.trim();
}

/*
 * Generate interview question
 */
app.post("/api/generate-question", async (req, res) => {
  try {
    const { role } = req.body;

    if (!role || typeof role !== "string") {
      return res.status(400).json({
        error: "Role is required.",
      });
    }

    const prompt = `
You are a professional technical interviewer.

The candidate is preparing for a ${role} interview.

Generate exactly ONE interview question.

Requirements:
- Make it relevant to the ${role} role.
- Keep it clear and realistic.
- Do not provide the answer.
- Do not add explanations.
- Do not number the question.
- Return only the question.
`;

    const question = await askGroq([
      {
        role: "system",
        content:
          "You are an expert technical interviewer who asks concise, realistic interview questions.",
      },
      {
        role: "user",
        content: prompt,
      },
    ]);

    return res.json({
      question,
    });
  } catch (error) {
    console.error("Generate question error:", error);

    return res.status(500).json({
      error: "Unable to generate interview question.",
    });
  }
});

/*
 * Evaluate candidate answer
 */
app.post("/api/evaluate-answer", async (req, res) => {
  try {
    const { question, answer, role } = req.body;

    if (!question || !answer || !role) {
      return res.status(400).json({
        error: "Question, answer and role are required.",
      });
    }

    const prompt = `
Evaluate a candidate's answer for a ${role} technical interview.

Interview Question:
${question}

Candidate Answer:
${answer}

Provide the evaluation in exactly this format:

Score: X/10

Strengths:
- strength 1
- strength 2

Improvements:
- improvement 1
- improvement 2

Overall Feedback:
A short professional paragraph explaining the quality of the answer and how the candidate can improve.

Be fair and constructive.
Do not invent information about the candidate.
`;

    const feedback = await askGroq([
      {
        role: "system",
        content:
          "You are an experienced technical interviewer evaluating candidates fairly and constructively.",
      },
      {
        role: "user",
        content: prompt,
      },
    ]);

    return res.json({
      feedback,
    });
  } catch (error) {
    console.error("Evaluate answer error:", error);

    return res.status(500).json({
      error: "Unable to evaluate interview answer.",
    });
  }
});

/*
 * Unknown endpoint
 */
app.use((req, res) => {
  res.status(404).json({
    error: "Endpoint not found.",
  });
});

/*
 * Start server
 */
app.listen(PORT, "0.0.0.0", () => {
  console.log("======================================");
  console.log("      MockMate AI Backend Started");
  console.log("======================================");
  console.log(`Server running on port ${PORT}`);
  console.log(`Model : ${MODEL}`);
});