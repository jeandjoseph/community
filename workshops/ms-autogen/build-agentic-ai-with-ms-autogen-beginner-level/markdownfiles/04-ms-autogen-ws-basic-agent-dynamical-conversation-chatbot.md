#
<h1 style="color:white; text-align:center;">
Microsoft AutoGen Multi-Agent Dynamic Multi-Turn Conversation Chatbot Application
</h1>

This part of the AI agent demo showcases how to integrate agentic AI into a chatbot application using Microsoft AutoGen and Streamlit. The backend script sets up a debate between three AI agents—Jean (a Data Engineer), Daniel (an AI Engineer), and a Moderator—using AutoGen's AssistantAgent and RoundRobinGroupChat classes. 

These agents interact in a structured, turn-based conversation moderated by predefined rules. The frontend, built with Streamlit, provides a user-friendly interface where users can input a debate topic and watch the conversation unfold in real time. This demo highlights how to orchestrate multi-agent interactions and stream their outputs dynamically in a web app.


#### ✅ Steps to follow:
1. Copy and paste below codes into a Python file, and save it as: `ai_agent_debating.py`
2. Copy and paste below codes into a Python file, and save it as: `agent-app-chat-without-state.py`
3. Activate your Python virtual environment to ensure dependencies are correctly managed.
   
4. Run the script using the terminal

Now let us get started with Step 1: 
   1. Copy and paste below codes into a Python file, and save it as: `ai_agent_debating.py`

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
async def initialize_ai_debate_team(subject):
    model_client = AzureOpenAIChatCompletionClient(
        azure_deployment=azure_openai_model_name,
        azure_endpoint=azure_openai_endpoint,
        model=azure_openai_model_name,
        api_version=azure_openai_api_version,
        api_key=azure_openai_api_key,
    )

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
            "and Daniel, an AI Engineer agent. Your role is to guide and moderate the discussion. "
            f"The subject of the debate is: {subject}."
            "\n\nInstructions:"
            "\n1. At the start of each round, announce the round number."
            "\n2. At the beginning of Round 3, state that it is the final round."
            "\n3. After the final round, thank the audience and say exactly: \"TERMINATE\"."
        )
    )

    team = RoundRobinGroupChat(
        participants=[Moderator, Daniel, Jean],
        max_turns=15,
        termination_condition=TextMentionTermination(text="TERMINATE")
    )

    return team

async def run_ai_gent_debate(team):
    async for message in team.run_stream(task="Start the debate!"):
        if isinstance(message, TaskResult):
            message = f'Stopping reason: {message.stop_reason}'
            yield message
        else:
            message = f'{message.source}: {message.content}'
            yield message
async def main():
    topic = "Shall US government ban TikTok?"
    team = await initialize_ai_debate_team(topic)
    async for message in run_ai_gent_debate(team):
        print('-' * 200)
        print(message)

if __name__ == '__main__':
    asyncio.run(main())
````

2. Copy and paste below codes into a Python file, and save it as: `agent-app-chat-without-state.py`

````python
import streamlit as st
import asyncio
from ai_agent_debating import initialize_ai_debate_team, run_ai_gent_debate

st.set_page_config(page_title="Agents Debate", layout="centered")
st.title("🤖 Agents Debate!")

# Input for debate topic
Subject = st.text_input("🎯 Enter the subject of the debate:", "Let the Debate Begin")

# Start button
clicked = st.button("Start Debate", type="primary")

# Container for chat messages
chat = st.container()

# Async function to run the debate
async def main():
    team = await initialize_ai_debate_team(Subject)
    with chat:
        async for message in run_ai_gent_debate(team):
            if message.startswith("Jean"):
                with st.chat_message(name='Jean', avatar="🧑‍💻"):
                    st.write(message)
            elif message.startswith("Daniel"):
                with st.chat_message(name='Daniel', avatar="🤖"):
                    st.write(message)
            elif message.startswith("Moderator"):
                with st.chat_message(name='Moderator', avatar="🎤"):
                    st.write(message)
            else:
                st.write(message)

# Run the async function only when the button is clicked
if clicked:
    try:
        asyncio.run(main())
        st.balloons()
    except RuntimeError as e:
        # Handles Streamlit's event loop conflict
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(main())
````
2. Activate your Python virtual environment to ensure dependencies are correctly managed.
   
3. Run the script using the terminal: example: 
   ````python
   streamlit run .\agent-app-chat-without-state.py 
   ````

