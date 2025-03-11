// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import wso2/ai.agent;

isolated class OllamaModel {
    *agent:ChatLlmModel; // extends Chat API interface
    *agent:FunctionCallLlmModel; // extends FunctionCall API interface
    final OllamaClient llmClient;

    function init(ConnectionConfig connectionConfig) returns error? {
        self.llmClient = check new (connectionConfig);
    }

    // agent:ChatMessage message[] => [{
    //     role: agent:Role.USER | agent:Role.SYSTEM | agent:Role.ASSISTANT,
    //     content: "Hello"
    // }]

    // ollama:Message message[] => [{
    //     role: "user" | "system" | "assistant",
    //     content: "Hello"
    // }]

    // function convertToOllamaMessages(agent:ChatMessage[] messages) returns ollama:Message[] {
    //     ollama:Message[] ollamaMessages = [];
    //     foreach var message in messages {
    //         ollama:Message ollamaMessage = {
    //             role: message.role.toString().toLowerAscii(),
    //             content: message.content
    //         };
    //         ollamaMessages.push(ollamaMessage);
    //     }
    //     return ollamaMessages;
    // }

    // public isolated function chatComplete(agent:ChatMessage[] messages, string? stop = ()) returns string|agent:LlmError {
    //     GenerateRequest payload = {
    //         model: "llama3.2:3b",
    //         prompt: "Hello how are you",
    //         'stream: false
    //     };
    //     GenerateResponse|error response = self.llmClient->/generate.post(payload);
    //     if response is error {
    //         return error agent:LlmConnectionError("Error while connecting to the model", response);
    //     }
    //     string? content = response.response;
    //     return content ?: error agent:LlmInvalidResponseError("Empty response from the model");
    // }

    public isolated function chatComplete(agent:ChatMessage[] messages, string? stop = ()) returns string|agent:LlmError {
        Message[]|ConversionError convertedMessages = convertChatMessagesToMessages(messages);
        if convertedMessages is ConversionError {
            return error agent:LlmError("Conversion error while running chat complete");
        }
        ChatRequest payload = {
            model: "llama3.2:3b",
            messages: convertedMessages,
            'stream: false
        };
        ChatResponse|error response = self.llmClient->/chat.post(payload);
        if response is error {
            return error agent:LlmConnectionError("Error while connecting to the model", response);
        }
        Message? message = response.message;
        string? content = message?.content;
        return content ?: error agent:LlmInvalidResponseError("Empty response from the model");
    }


    public isolated function functionCall(agent:ChatMessage[] messages, agent:ChatCompletionFunctions[] functions, string? stop) returns string|agent:FunctionCall|agent:LlmError {
        // implement to call function call API of the new LLM
        // return the function call or the text content if the response is a chat response
        return {name: "FUNCTION_NAME", arguments: "FUNCTION_ARGUMENTS"};
    }
}
