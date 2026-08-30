import { config, isGeminiConfigured } from "../config";

export interface GenerateImageInput {
  selfieBase64: string;
  styleReferenceBase64: string;
  statsCardBase64: string;
  styleTier: "flash" | "pro";
}

const GEMINI_MODELS = {
  flash: "gemini-3.1-flash-image",
  pro: "gemini-3-pro-image",
} as const;

/**
 * Composites the selfie (character reference), the fixed style-reference
 * image, and the on-device-rendered stats card (object reference) into one
 * image. Falls back to returning the selfie unmodified (mock mode) until a
 * Gemini API key is configured.
 */
export async function generateComposite(input: GenerateImageInput): Promise<string> {
  if (!isGeminiConfigured()) {
    return input.selfieBase64;
  }

  const model = GEMINI_MODELS[input.styleTier];
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${config.gemini.apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: "Combine these into one stylized cartoon avatar: the character reference (selfie), the art style reference, and the stats card as a held object. Keep the stats card's text and numbers pixel-exact.",
              },
              { inlineData: { mimeType: "image/jpeg", data: input.selfieBase64 } },
              { inlineData: { mimeType: "image/png", data: input.styleReferenceBase64 } },
              { inlineData: { mimeType: "image/png", data: input.statsCardBase64 } },
            ],
          },
        ],
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`Gemini generateContent failed: ${response.status}`);
  }

  const result = (await response.json()) as {
    candidates?: { content?: { parts?: { inlineData?: { data?: string } }[] } }[];
  };
  const imageBase64 = result.candidates?.[0]?.content?.parts?.find((part) => part.inlineData?.data)?.inlineData
    ?.data;
  if (!imageBase64) {
    throw new Error("Gemini response contained no image data");
  }
  return imageBase64;
}
