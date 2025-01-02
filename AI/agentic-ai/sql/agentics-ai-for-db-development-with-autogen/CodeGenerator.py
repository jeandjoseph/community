import autogen

class CodeGeneratorManager:
    def __init__(self, config_file="AOAI_CONFIG_LIST.json",
                 file_location=".",
                 model="gpt-4o",
                 cache_seed=None,
                 temperature=0,
                 timeout=120,
                 tsql_coder_agent_system_message="",
                 python_coder_agent_system_message=""):
        # Load configuration list from JSON file
        self.config_list = autogen.config_list_from_json(
            env_or_file=config_file,
            file_location=file_location,
            filter_dict={
                "model": {
                    model
                }
            },
        )
        
        # Set up LLM configuration
        self.llm_config = {
            "cache_seed": cache_seed,
            "temperature": temperature,
            "config_list": self.config_list,
            "timeout": timeout,
        }

        # Initialize system messages for agents
        self.tsql_coder_agent_system_message = tsql_coder_agent_system_message
        self.python_coder_agent_system_message = python_coder_agent_system_message

        # Initialize T-SQL coder agent
        self.tsql_coder_agent = autogen.AssistantAgent(
            name="tsql_coder_agent",
            llm_config=self.llm_config,
            system_message=self.tsql_coder_agent_system_message
        )

        # Initialize Python coder agent
        self.python_coder_agent = autogen.AssistantAgent(
            name="python_coder_agent",
            llm_config=self.llm_config,
            system_message=self.python_coder_agent_system_message
        )

        # Initialize user proxy agent
        self.user_proxy = autogen.UserProxyAgent(
            name="sql_user_proxy",
            is_termination_msg=lambda msg: msg.get("content") is not None and "TERMINATE" in msg["content"],
            human_input_mode="NEVER",
            max_consecutive_auto_reply=1,
            code_execution_config={"use_docker": False}
        )

        # Set up group chat with agents
        self.group_chat = autogen.GroupChat(
            agents=[self.tsql_coder_agent, self.python_coder_agent, self.user_proxy],
            messages=[],
            max_round=4,
            enable_clear_history=True,
            allow_repeat_speaker=False
        )
        
        # Initialize group chat manager
        self.manager = autogen.GroupChatManager(
            self.group_chat,
            llm_config=self.llm_config
        )