
#
<h1 style="color:white; text-align:center;">
Microsoft AutoGen Multi-Agent Fixed Multi-Turn Conversation
</h1>
This workshop script shows how two AI agents—Jean and Daniel—can take turns responding in a way that feels like a real conversation, using Microsoft AutoGen 0.4’s RoundRobinGroupChat strategy to simulate a structured, back-and-forth dialogue.

In Microsoft AutoGen 0.4, the framework introduces agent selection strategies that determine how messages are routed among multiple agents. These strategies fall into two broad categories: deterministic and non-deterministic, and they play a crucial role in shaping how agentic AI systems behave.

### 🔁 RoundRobinGroupChat – Deterministic
- **How it works**: Agents take turns in a fixed, circular order.
- **Behavior**: Every agent gets a chance to respond in sequence, and each response is broadcast to all other agents.
- **Use case**: Ideal for structured collaboration where each agent contributes equally and context is shared.
- **Key trait**: Deterministic — the order of agent turns is predictable and repeatable.
- **Example**: Agent A → Agent B → Agent C → Agent A...

This is useful when you want fairness and transparency in agent participation.

### 🎯 SelectOneGroupChat – Non-Deterministic
- **How it works**: After each message, a model (usually an LLM) selects the next agent to respond.
- **Behavior**: Only one agent is chosen to reply at each step, based on context or relevance.
- **Use case**: Efficient when only one agent needs to act or when you want to avoid redundant responses.
- **Key trait**: Non-deterministic — the next speaker is chosen dynamically, not in a fixed order.

This is great for expert selection or when minimizing noise in the conversation.

### 🧲 MagenticOneGroupChat – Context-Aware & Adaptive
- **How it works**: Agents are selected based on their "magnetism" to the task—i.e., how relevant or capable they are in the current context.
- **Behavior**: The system dynamically routes tasks to the most appropriate agent(s), often using memory, prior performance, or domain expertise.
- **Use case**: Best for complex, open-ended tasks where agent specialization matters.
- **Key trait**: Non-deterministic and intelligent — agent selection is adaptive and optimized for task relevance.

Think of this as a smart routing system that picks the best agent for the job at each step.

### 🧠 GroupChat Strategy Summary in Microsoft AutoGen

| Strategy              | Determinism       | Agent Turn Logic                  | Best For                                 |
|-----------------------|-------------------|-----------------------------------|-------------------------------------------|
| `RoundRobinGroupChat` | Deterministic     | Fixed circular order              | Equal participation, structured dialogue  |
| `SelectOneGroupChat`  | Non-deterministic | LLM selects one agent to respond  | Focused replies, expert selection         |
| `MagenticOneGroupChat`| Non-deterministic | Context-aware agent selection     | Adaptive, intelligent task routing        |


Our focus is on building a deterministic Microsoft AutoGen agent, which necessitates using the RoundRobinGroupChat to ensure predictable, sequential message passing among agents. This structure avoids randomness in agent selection, aligning with our deterministic design goals. 

Additionally, we distinguish between `run()` and `run_stream()` in asyncio:` run()` executes the full conversation and returns the final result, while `run_stream()` yields intermediate steps in real time, offering more granular control and visibility during execution.

#
Our first demo uses `asyncio.run()` to execute a deterministic AutoGen conversation with RoundRobinGroupChat, returning the final result after completing the full dialogue.

#### ✅ Steps to follow:
1. Copy and paste the code into a Python file, and save it: example - autogen_demo_run.py
2. Activate your Python virtual environment to ensure dependencies are correctly managed.
3. Run the script using the terminal: Observe how the agents communicate in a multi-turn conversation with deterministic sequencing.

Once complete, we’ll explore the run_stream() generator for real-time interaction and step-by-step output.

````bash
import os
from dotenv import load_dotenv

from autogen_ext.models.openai import AzureOpenAIChatCompletionClient  
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.teams import RoundRobinGroupChat
import asyncio


# Load environment variables from .env file
load_dotenv()

# Retrieve environment variables
azure_openai_model_name = os.getenv("MODEL")
azure_openai_api_key = os.getenv("API_KEY")
azure_openai_endpoint = os.getenv("BASE_URL")
azure_openai_api_type = os.getenv("API_TYPE")
azure_openai_api_version = os.getenv("API_VERSION")

# Print retrieved environment variables
print(azure_openai_endpoint)
print(azure_openai_model_name)
print(azure_openai_api_version)


# Define an async function to interact with the model client
async def interact_with_model(user_message):
    model_client = AzureOpenAIChatCompletionClient(
        azure_deployment=azure_openai_model_name,
        azure_endpoint=azure_openai_endpoint,
        model=azure_openai_model_name,
        api_version=azure_openai_api_version,
        api_key=azure_openai_api_key,
    )

    # Create a user message and get the response from the model client
    subject = "clean datasets in the machine learning process"
    Jean = AssistantAgent(
     name="Jean",
        model_client=model_client,
        system_message=(
            "You are Jean, a Data Engineer. "
            "Your task is to clearly and very concisely explain the importance of {subject}. "
            "Focus on being brief, direct, and informative. "
            "Make sure you introduce yourself as Jean, a Data Engineer, at only the start of the first conversation. "
     ),
    )


    Daniel = AssistantAgent(
        name="Daniel",
        model_client=model_client,
        system_message=(
            "You are Daniel, an AI Engineer. "
            "Begin conversations by discussing anout the {subject}. "
            "Be concise and focus specifically on data cleansing and feature engineering. "
            "Make sure you introduce yourself as Daniel, an AI Engineer, at only the start of the first conversation."
     ),
    )

    team = RoundRobinGroupChat(
        participants=[Daniel, Jean],
        max_turns=3,
    )
   
    res= await team.run(task=user_message)
    
    for message in res.messages:
        print('='*100)
        print(f"{message.source}: {message.content}")

# Loop to get user input until "done" is typed
def main():
    while True:
        user_input = input("Enter your message (type 'done' to exit): ").strip()
        if user_input.lower() == "done":
            break
        asyncio.run(interact_with_model(user_input))

# Run the main loop
if __name__ == "__main__":
    main()
````

We just explored run(), which waits for the entire conversation to finish before showing results. Now, let’s shift to run_stream(). The key difference is that run_stream() is an async generator—it lets us observe the conversation step by step as it unfolds. Unlike regular functions that reset after returning, generators remember where they left off and resume from the last yield, making them perfect for interactive, real-time experimentation.

When using `run_stream()`, make sure to import `TaskResult` with `from autogen_agentchat.base import TaskResult`. This is essential because each step in the stream yields a TaskResult object, which holds the intermediate output of the conversation. Without this import, you won’t be able to properly access or interpret the streamed results as they come in.

### 🔄 Code Update Summary

In this version, we made two key changes:

1️⃣ **Replaced the blocking `run()` call with the streaming `run_stream()`** to observe the conversation step by step:

```python
# ❌ Old approach from above scripts
res = await team.run(task=user_message)
for message in res.messages:
    print('='*100)
    print(f"{message.source}: {message.content}")
`````

## ✅ New approach using run_stream
```python
async for res in team.run_stream(task=user_message):
    print('='*100)
    if isinstance(res, TaskResult):
        print(f'Stopping reason: {res.stop_reason}')
    else:
        print(f'{res.source}: {res.content}')
`````

2️⃣ 🧹 Removed the looped conversation logic to focus on a single, streamable interaction for clarity and experimentation.

````python
import os
import asyncio
from dotenv import load_dotenv

from autogen_ext.models.openai import AzureOpenAIChatCompletionClient  
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.base import TaskResult

# Load environment variables from .env file
load_dotenv()

# Retrieve environment variables
azure_openai_model_name = os.getenv("MODEL")
azure_openai_api_key = os.getenv("API_KEY")
azure_openai_endpoint = os.getenv("BASE_URL")
azure_openai_api_type = os.getenv("API_TYPE")
azure_openai_api_version = os.getenv("API_VERSION")

# Print retrieved environment variables
print("Endpoint:", azure_openai_endpoint)
print("Model:", azure_openai_model_name)
print("API Version:", azure_openai_api_version)

# Define an async function to interact with the model client
async def run_ai_agent_debate(user_message):
    model_client = AzureOpenAIChatCompletionClient(
        azure_deployment=azure_openai_model_name,
        azure_endpoint=azure_openai_endpoint,
        model=azure_openai_model_name,
        api_version=azure_openai_api_version,
        api_key=azure_openai_api_key,
    )

    subject = "clean datasets in the machine learning process"

    Jean = AssistantAgent(
        name="Jean",
        model_client=model_client,
        system_message=(
            f"You are Jean, a Data Engineer. "
            f"Your task is to clearly and very concisely explain the importance of {subject}. "
            f"Focus on being brief, direct, and informative. "
            f"Make sure you introduce yourself as Jean, a Data Engineer, at only the start of the first conversation."
        ),
    )

    Daniel = AssistantAgent(
        name="Daniel",
        model_client=model_client,
        system_message=(
            f"You are Daniel, an AI Engineer. "
            f"Begin conversations by discussing about the {subject}. "
            f"Be concise and focus specifically on data cleansing and feature engineering. "
            f"Make sure you introduce yourself as Daniel, an AI Engineer, at only the start of the first conversation."
        ),
    )

    team = RoundRobinGroupChat(
        participants=[Daniel, Jean],
        max_turns=3,
    )

    async for res in team.run_stream(task=user_message):
        print('-' * 20)
        if isinstance(res, TaskResult):
            print(f'Stopping reason: {res.stop_reason}')
        else:
            print(f'{res.source}: {res.content}')

# Run the main loop
if __name__ == "__main__":
    user_message = input("Enter your message (type 'done' to exit): ").strip()
    if user_message.lower() != 'done':
        asyncio.run(run_ai_agent_debate(user_message))
````

### 👀 Observation During `run_stream()` Execution

Notice that during execution with `run_stream()`, we can observe the conversation unfold **step by step** in real time. Each message is streamed as it’s generated, allowing us to monitor the interaction live—unlike `run()`, which only shows the full conversation after it completes. This makes `run_stream()` ideal for debugging, experimentation, and interactive applications.


### ✨ Share Your Experience

We hope this demo helped you understand how Microsoft AutoGen 0.4 enables structured, realistic conversations between AI agents. If you found this experience insightful or enjoyable, feel free to leave a comment and share your thoughts—your feedback helps us improve and shape future workshops!
