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

import ballerina/io;

import wso2/ai.agent;

public function main() returns error? {
    OllamaModel ollamaModel = check new (connectionConfig = {});
    string[] userMessages = [
        "Explain quantum mechanics in simple terms.",
        "What is entanglement?",
        "How is it used in computing?",
        "Who are key scientists?",
        "What are real-world applications?"
    ];
    agent:ChatMessage chatMessage;
    agent:ChatMessage[] chatMessages = [];
    foreach int i in int:range(0, userMessages.length(), 1) {
        chatMessage = {
            role: agent:USER,
            content: userMessages[i]
        };
        io:println(chatMessage);
        chatMessages.push(chatMessage);
        string|agent:LlmError assistantMessage = ollamaModel.chatComplete(chatMessages);
        if assistantMessage is string {
            chatMessage = {
                role: agent:ASSISTANT,
                content: assistantMessage
            };
            chatMessages.push(chatMessage);
            io:println(chatMessage);
        } else {
            return assistantMessage;
        }
    }
}
