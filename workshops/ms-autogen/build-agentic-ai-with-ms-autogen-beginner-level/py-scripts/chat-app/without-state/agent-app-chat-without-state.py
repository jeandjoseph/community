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

