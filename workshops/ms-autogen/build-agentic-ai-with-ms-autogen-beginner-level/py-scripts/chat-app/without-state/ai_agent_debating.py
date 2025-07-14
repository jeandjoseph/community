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
