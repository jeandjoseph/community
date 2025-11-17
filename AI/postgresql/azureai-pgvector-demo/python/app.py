import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor
from typing import Any, Dict, List, Optional

import pandas as pd
import streamlit as st

# -------------------------------------------------------------------
# Import your PostgresClient class
from azPostgresqlConnection import PostgresClient  # Ensure this file contains the class we built
# -------------------------------------------------------------------

st.set_page_config(page_title="Function Runner", page_icon="🔎", layout="wide")
st.title("🔎 Interact Boldly. Your Data, Your Privacy.")
st.caption("Chat with your private data, explore related responses, choose the best fit, and uncover detailed insights on the specified product and its reviews.")

# ======================
# Session State Init
# ======================
if "history" not in st.session_state:
    st.session_state.history: List[Dict[str, Any]] = []

if "last_results" not in st.session_state:
    st.session_state.last_results: Optional[Any] = None

if "preset_queries" not in st.session_state:
    st.session_state.preset_queries: Dict[str, str] = {}

# ======================
# Cache DB Client
# ======================
@st.cache_resource(show_spinner=False)
def get_client():
    return PostgresClient()

# ======================
# Function Presets
# ======================
FUNCTION_PRESETS = [
    {
        "label": "Looking for similar items? Just ask!",
        "query_placeholder": "e.g., lightweight laptop with long battery life",
        "query_help": "Describe what you’re looking for; we’ll match similar items.",
        "default_query": "lightweight laptop with long battery life",
    },
    {
        "label": "Find a specific product overview",
        "query_placeholder": "e.g., ThinkPad X1 Carbon Gen 11",
        "query_help": "Enter an exact product, brand, or model name.",
        "default_query": "",
    },
    {
        "label": "Find accessories by device",
        "query_placeholder": "e.g., iPhone 15 Pro Max cases",
        "query_help": "Type the device and the accessory type.",
        "default_query": "",
    },
    {
        "label": "Query by SKU or ID",
        "query_placeholder": "e.g., SKU-ABC-12345",
        "query_help": "Provide an exact SKU or internal ID.",
        "default_query": "",
    },
]
PRESETS_BY_LABEL = {p["label"]: p for p in FUNCTION_PRESETS}

# ======================
# Helpers
# ======================
def to_dataframe(results):
    """Convert query result dict into DataFrame with real column names."""
    if not results or "rows" not in results or "columns" not in results:
        return pd.DataFrame()
    return pd.DataFrame(results["rows"], columns=results["columns"])

def call_db(function_label: str, query_text: str):
    """Invoke the DB function using PostgresClient."""
    client = get_client()
    return client.call_function(function_label, query_text)

def append_history(function_label: str, query_text: str, results: Any):
    df = to_dataframe(results)
    record = {
        "ts": datetime.now().isoformat(timespec="seconds"),
        "function_name": function_label,
        "query_text": query_text,
        "row_count": int(len(df)) if hasattr(df, "__len__") else 0,
        "results": results,
    }
    st.session_state.history.append(record)

# ======================
# UI: Preset Dropdown + Query input + Submit
# ======================
col1, col2, col3 = st.columns([1.6, 2.4, 0.9])

with col1:
    selected_label = st.selectbox(
        "Choose an Action",
        options=[p["label"] for p in FUNCTION_PRESETS],
        index=0,
        help="Actions are mapped to Postgres functions and help guide your queries.",
        key="function_preset_select"
    )
    selected = PRESETS_BY_LABEL[selected_label]
    st.caption(f"Function to execute: `{selected_label}`")

with col2:
    last_q = st.session_state.preset_queries.get(selected_label, selected.get("default_query", ""))
    query_text = st.text_input(
        "Describe What You Need",
        value=last_q,
        placeholder=selected["query_placeholder"],
        help=selected["query_help"],
        key=f"query_input_{selected_label}",
    )

with col3:
    run = st.button("Submit", type="primary", use_container_width=True)

# ======================
# Progress + Submit handler
# ======================
status_box = st.empty()
progress_bar = st.empty()

if run:
    if not selected_label or not query_text:
        st.warning("Please provide both **Function preset** and **Query text**.")
        st.stop()

    status_box.info("Submitting job to database…")
    prog = progress_bar.progress(0)

    with ThreadPoolExecutor(max_workers=1) as executor:
        future = executor.submit(call_db, selected_label, query_text)
        pct = 0
        while not future.done():
            pct = (pct + 7) % 100
            prog.progress(pct + 1)
            status_box.info("Running… fetching results from Postgres.")
            time.sleep(0.12)
        prog.progress(100)

        try:
            results = future.result()
            st.session_state.last_results = results
            append_history(selected_label, query_text, results)
            st.session_state.preset_queries[selected_label] = query_text
            status_box.success("Done! Results retrieved.")
        except Exception as e:
            status_box.error(f"Error while running the function: {e}")

# ======================
# Latest Results Panel
# ======================
if st.session_state.last_results is not None:
    st.subheader("Latest Results")
    df_latest = to_dataframe(st.session_state.last_results)
    if df_latest.empty:
        st.warning("No results found.")
    else:
        st.dataframe(df_latest, use_container_width=True, hide_index=True)
    with st.expander("Raw output"):
        st.write(st.session_state.last_results)

st.markdown("---")

# ======================
# History Panel
# ======================
left, right = st.columns([3, 1])

with left:
    st.subheader("📜 Transaction History (this session)")
    if len(st.session_state.history) == 0:
        st.info("No history yet. Submit a query to populate this panel.")
    else:
        for i, rec in enumerate(reversed(st.session_state.history), start=1):
            original_idx = len(st.session_state.history) - i
            header = f"[{rec['ts']}] {rec['function_name']} — “{rec['query_text']}” • rows: {rec['row_count']}"
            with st.expander(header, expanded=False):
                df = to_dataframe(rec["results"])
                if not df.empty:
                    st.dataframe(df, use_container_width=True, hide_index=True)
                else:
                    st.write("_No rows returned._")

                c1, c2 = st.columns([0.25, 0.75])
                with c1:
                    if st.button("Re-run", key=f"rerun_{original_idx}"):
                        try:
                            new_results = call_db(rec["function_name"], rec["query_text"])
                            st.session_state.last_results = new_results
                            append_history(rec["function_name"], rec["query_text"], new_results)
                            st.rerun()
                        except Exception as e:
                            st.error(f"Re-run failed: {e}")
                with c2:
                    with st.expander("Raw output", expanded=False):
                        st.write(rec["results"])

with right:
    st.subheader("Tools")
    if st.button("Clear history"):
        st.session_state.history.clear()
        st.session_state.last_results = None
        st.success("History cleared for this session.")
        st.rerun()

    if len(st.session_state.history) > 0:
        hist_df = pd.DataFrame(
            [
                {
                    "timestamp": r["ts"],
                    "function_name": r["function_name"],
                    "query_text": r["query_text"],
                    "row_count": r["row_count"],
                }
                for r in st.session_state.history
            ]
        )
        st.download_button(
            "Download history (CSV)",
            data=hist_df.to_csv(index=False).encode("utf-8"),
            file_name="function_history.csv",
            mime="text/csv"
        )

with st.sidebar:
    st.markdown("### ℹ️ Tips")
    st.write(
        "- Choose a **Function preset** to set the underlying Postgres function.\n"
        "- The **Query text** field adapts its placeholder and help based on the preset.\n"
        "- Progress bar loops while the query executes; it completes when the call returns.\n"
        "- Your **transaction history** persists during this browser session."
    )