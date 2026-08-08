const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { setGlobalOptions } = require("firebase-functions/v2/options");
const logger = require("firebase-functions/logger");

setGlobalOptions({
  region: "us-central1",
  maxInstances: 5,
});

const XAI_API_KEY = defineSecret("XAI_API_KEY");

const XAI_URL = "https://api.x.ai/v1/chat/completions";
const XAI_MODEL = "grok-4.5";

exports.mockmateAI = onCall(
  {
    secrets: [XAI_API_KEY],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request) => {
    // Only authenticated MockMate users can call the AI.
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be logged in to use MockMate AI."
      );
    }

    const data = request.data || {};
    const action = data.action;

    if (action !== "generateQuestion" && action !== "evaluateAnswer") {
      throw new HttpsError(
        "invalid-argument",
        "Invalid AI action."
      );
    }

    const role = String(data.role || "").trim();

    if (!role) {
      throw new HttpsError(
        "invalid-argument",
        "Interview role is required."
      );
    }

    let messages;

    if (action === "generateQuestion") {
      messages = [
        {
          role: "system",
          content:
            "You are a professional technical interviewer. " +
            "Generate realistic, clear and concise interview questions.",
        },
        {
          role: "user",
          content:
            `Ask ONE technical interview question for a ${role} job role. ` +
            "Do not provide the answer. " +
            "Return only the interview question.",
        },
      ];
    } else {
      const question = String(data.question || "").trim();
      const answer = String(data.answer || "").trim();

      if (!question) {
        throw new HttpsError(
          "invalid-argument",
          "Interview question is required."
        );
      }

      if (!answer) {
        throw new HttpsError(
          "invalid-argument",
          "Candidate answer is required."
        );
      }

      messages = [
        {
          role: "system",
          content:
            "You are a professional technical interviewer. " +
            "Evaluate candidate answers fairly and provide concise, actionable feedback.",
        },
        {
          role: "user",
          content:
            `Evaluate the following answer for a ${role} interview.\n\n` +
            `Question:\n${question}\n\n` +
            `Candidate Answer:\n${answer}\n\n` +
            "Provide:\n" +
            "1. Score out of 10\n" +
            "2. Strengths\n" +
            "3. Improvements\n\n" +
            "Keep the response concise and useful for the candidate.",
        },
      ];
    }

    try {
      const apiKey = XAI_API_KEY.value();

      if (!apiKey) {
        logger.error("XAI_API_KEY is not configured.");
        throw new HttpsError(
          "failed-precondition",
          "AI service is not configured."
        );
      }

      const response = await fetch(XAI_URL, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: XAI_MODEL,
          messages,
          temperature: action === "generateQuestion" ? 0.7 : 0.4,
          max_tokens: action === "generateQuestion" ? 150 : 300,
        }),
      });

      const responseText = await response.text();

      logger.info("xAI response status", {
        status: response.status,
        action,
      });

      if (!response.ok) {
        logger.error("xAI API error", {
          status: response.status,
          body: responseText,
        });

        throw new HttpsError(
          "internal",
          `AI provider returned an error (${response.status}).`
        );
      }

      let result;

      try {
        result = JSON.parse(responseText);
      } catch (error) {
        logger.error("Invalid JSON returned by xAI.", error);

        throw new HttpsError(
          "internal",
          "AI provider returned an invalid response."
        );
      }

      const content =
        result?.choices?.[0]?.message?.content;

      if (!content || !String(content).trim()) {
        logger.error("xAI returned an empty response.", {
          response: result,
        });

        throw new HttpsError(
          "internal",
          "AI provider returned an empty response."
        );
      }

      return {
        success: true,
        result: String(content).trim(),
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("Unexpected MockMate AI error.", error);

      throw new HttpsError(
        "internal",
        "Unable to process the AI request."
      );
    }
  }
);