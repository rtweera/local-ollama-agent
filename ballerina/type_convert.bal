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

# Converts a `ChatMessage` to a `Message`.
#
# + chatMessage - The `ChatMessage` to be converted
# + return - Returns the converted `Message` or a `ConversionError` if the conversion fails
public isolated function convertChatMessageToMessage(agent:ChatMessage chatMessage) returns Message|ConversionError {
    Message message = {
        role: "user",
        content: "",
        images: [],
        tool_calls: []
    };
    match chatMessage {
        // Handle ChatUserMessage
        // { role: agent:USER, content: var content }
        var { role, content } if role == agent:USER => {
            message.role = "user";
            if content is () || content.trim().length() == 0 {
                return error ConversionError("Content is empty for user message");
            }
            message.content = content;
        }
        // Handle ChatSystemMessage
        // { role: agent:SYSTEM, content: var content }
        var { role, content } if role == agent:SYSTEM => {
            message.role = "system";
            if content is () || content.trim().length() == 0 {
                return error ConversionError("Content is empty for a system message");
            }
            message.content = content;
        }

        // Handle ChatFunctionMessage
        var { role, content, name } if role == agent:FUNCTION => {
            if name.trim().length() == 0 {
                return error ConversionError("Function name is empty");
            }
            message.role = "assistant";
            message.content = content ?: "";
            message.tool_calls = [{
                "name": name,
                "arguments": ""
            }];
        }
                // Handle ChatAssistantMessage
        // { role: agent:ASSISTANT, content: var content_, name: _, functionCall: var functionCall }
        var { role, content, ...rest } if role == agent:ASSISTANT => {
            if content is () && !rest.hasKey("function_call") {
                return error ConversionError("content and function call both empty for role: assistant");
            }
            message.role = "assistant";
            if content is string {
                message.content = content;
            }
            agent:FunctionCall? function_call = rest["function_call"];
            if function_call is agent:FunctionCall {
                message.tool_calls = [{
                    "name": function_call.name,
                    "arguments": function_call.arguments
                }];
            }
        }
        // Handle unexpected cases
        _ => {
            return error ConversionError("Unknown and invalid message role");
        }
    }
    return message;
}

public isolated function convertChatMessagesToMessages(agent:ChatMessage[] chatMessages) returns Message[]|ConversionError {
    return chatMessages.map(chatMessage => check convertChatMessageToMessage(chatMessage));
}