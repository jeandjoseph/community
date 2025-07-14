#
<h1 style="color:white; text-align:center;">
Microsoft AutoGen Multi-Agent Dynamic Multi-Turn Conversation
</h1>
### 🧠 Designing Agentic AI: A Quick Tip

When building agentic AI systems with Microsoft AutoGen, it's important to think carefully about **how and when your agents should stop talking**. Parameters like `max_turns` and `TextMentionTermination` aren’t just technical details—they shape the flow, clarity, and usefulness of your conversations.

✅ Use `max_turns` to keep things bounded and predictable. max_turns creates a fixed multi-turn conversation — think of it as a scripted exchange where the number of turns is predetermined. This is great for controlled demos or predictable agent behavior. 

🔄 Use `TextMentionTermination` when you want the conversation to end naturally based on content. The dialogue continues until a specific condition (like a keyword) is met. This allows for more flexible, goal-driven interactions.

Choosing the right strategy helps ensure your agents behave in a way that’s both intelligent and intentional.

### 🎯 **Demo Focus: Exploring Agent Roles and Termination Strategies**

This demo focuses on how agent roles and termination strategies affect conversation flow in Microsoft AutoGen. 

Let’s take it a step further by adding a third agent—a moderator—while still keeping the conversation under a **Fixed Multi-Turn Conversation** setup.

#
Our first demo focuses on a deterministic AutoGen conversation with a **Fixed Multi-Turn** Conversation.

#### ✅ Steps to follow:
1. Copy and paste the code into a Python file, and save it: example - autogen_demo3_run.py
2. Activate your Python virtual environment to ensure dependencies are correctly managed.
3. Run the script using the terminal: Observe how the agents communicate in a fixed multi-turn conversation with deterministic sequencing.

Pay close attention to how the dialogue flows and how it ends predictably after the set number of turns. Below, you’ll find a modified version of the script that shifts to a **Dynamic Multi-Turn Conversation**, where the conversation ends based on content rather than a fixed count.

```python
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


    Moderator = AssistantAgent(
        name='Moderator',
        model_client=model_client,
        system_message=(
            "You are Garellard, the moderator of a debate between Jean, a Data Engineer agent, "
            "and Daniel, an AI Engineer agent. Your role is to guide and moderate the discussion."
            f" The subject of the debate is: {subject}."
            "\n\nInstructions:"
            "\n1. At the start of each round, announce the round number."
            "\n2. At the beginning of Round 3, state that it is the final round."
            "\n3. After the final round, thank the audience and say exactly: \"TERMINATE\"."
        )
    )


    team = RoundRobinGroupChat(
        participants=[Moderator, Daniel, Jean],
        max_turns=15,
    )

    async for res in team.run_stream(task=user_message):
        print('-' * 300)
        if isinstance(res, TaskResult):
            print(f'Stopping reason: {res.stop_reason}')
        else:
            print(f'{res.source}: {res.content}')

# Run the main loop
if __name__ == "__main__":
    user_message = input("Enter your message (type 'done' to exit): ").strip()
    if user_message.lower() != 'done':
        asyncio.run(run_ai_agent_debate(user_message))
```


### 🛠️ What’s Modified in the Dynamic Version

This demo focuses on enabling **Dynamic Multi-Turn Conversation** using a content-based stopping condition.

Here’s what we changed:
- ✅ Imported the termination condition:
  ```python
  from autogen_agentchat.conditions import TextMentionTermination
  ```

✅ Added a termination rule to the RoundRobinGroupChat: 
`termination_condition = TextMentionTermination(text="TERMINATE")`

### 👀 What to Watch For

As you run this version, observe how the conversation flows more naturally. Instead of stopping abruptly after a fixed number of turns, the agents continue interacting until the keyword `"TERMINATE"` is mentioned. This creates a more flexible and realistic dialogue—closer to how real conversations unfold.

````python
import os
import asyncio
from dotenv import load_dotenv

from autogen_ext.models.openai import AzureOpenAIChatCompletionClient  
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.conditions import TextMentionTermination
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


    Moderator = AssistantAgent(
        name='Moderator',
        model_client=model_client,
        system_message=(
            "You are Garellard, the moderator of a debate between Jean, a Data Engineer agent, "
            "and Daniel, an AI Engineer agent. Your role is to guide and moderate the discussion."
            f" The subject of the debate is: {subject}."
            "\n\nInstructions:"
            "\n1. At the start of each round, announce the round number."
            "\n2. At the beginning of Round 3, state that it is the final round."
            "\n3. After the final round, thank the audience and say exactly: \"TERMINATE\"."
        )
    )


    team = RoundRobinGroupChat(
        participants=[Moderator, Daniel, Jean],
        max_turns=15,
        termination_condition = TextMentionTermination(text="TERMINATE")
    )

    async for res in team.run_stream(task=user_message):
        print('-' * 300)
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

### 🧩 To Summarize

This demo walked you through the two core conversation strategies in Microsoft AutoGen: **Fixed Multi-Turn**, which uses `max_turns` for predictable, structured exchanges, and **Dynamic Multi-Turn**, which leverages `TextMentionTermination` for more natural, context-aware dialogue. Each approach serves different goals whether you're aiming for control or flexibility in agent behavior.

🙏 We hope you found this experience insightful! If you enjoyed the demo or learned something new, feel free to share your satisfaction and feedback—it helps us make future sessions even better.
