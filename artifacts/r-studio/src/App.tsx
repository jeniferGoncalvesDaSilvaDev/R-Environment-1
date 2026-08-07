import { useMemo, useState } from 'react';
import {
  BarChart3,
  ChevronDown,
  ChevronRight,
  CircleHelp,
  Code2,
  Copy,
  Database,
  FileCode2,
  FilePlus2,
  FolderOpen,
  Gauge,
  GitBranch,
  Info,
  Lightbulb,
  Menu,
  MoreHorizontal,
  Moon,
  PanelLeft,
  Play,
  Plus,
  RotateCcw,
  Search,
  Settings2,
  Sun,
  Table2,
  Terminal,
  Trash2,
  X,
} from 'lucide-react';

type Script = {
  id: string;
  name: string;
  size: string;
  content: string;
  type: 'r' | 'md';
};

const starterScript = `# Exploring weekly bike share patterns
library(tidyverse)

rides <- read_csv("data/weekly_rides.csv")

weekly_summary <- rides |>
  group_by(week, member_type) |>
  summarise(
    rides = sum(trips),
    avg_duration = mean(duration_min),
    .groups = "drop"
  )

ggplot(weekly_summary, aes(week, rides, color = member_type)) +
  geom_line(linewidth = 1.1) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Weekly rides by membership",
    x = NULL, y = "Trips"
  )`;

const cleanScript = `# A small first analysis
library(tidyverse)

scores <- tibble(
  student = c("Mina", "Theo", "Ravi", "June"),
  score = c(87, 92, 78, 95)
)

scores |>
  summarise(
    average = mean(score),
    highest = max(score)
  )`;

const initialScripts: Script[] = [
  { id: 'weekly-rides', name: 'weekly_rides.R', size: '1.2 KB', content: starterScript, type: 'r' },
  { id: 'clean-script', name: 'clean_script.R', size: '0.8 KB', content: cleanScript, type: 'r' },
  { id: 'readme', name: 'README.md', size: '2.4 KB', content: '# Field notes\\n\\nA gentle place to explore the weekly rides dataset.', type: 'md' },
];

const initialConsole = [
  { text: '> source("weekly_rides.R")', kind: 'command' },
  { text: 'Rows: 1,248  |  Columns: 5', kind: 'dim' },
  { text: 'OK  weekly_summary created — 24 observations', kind: 'info' },
  { text: 'OK  Plot rendered in 0.42s', kind: 'info' },
  { text: '> ', kind: 'command' },
];

function escapeHtml(value: string) {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function highlightR(code: string) {
  const escaped = escapeHtml(code);
  return escaped.replace(
    /(#[^\n]*)|(&quot;(?:\\.|[^&]|&(?!quot;))*?&quot;)|\b(c|library|library|group_by|summarise|mean|max|sum|ggplot|aes|geom_line|scale_y_continuous|labs|read_csv|tibble|source|print)\b|\b(\d+(?:\.\d+)?)\b|(=&gt;|&lt;-|=|\+|-|\|&gt;)/g,
    (match, comment, string, keyword, number, operator) => {
      if (comment) return `<span class="token-comment">${comment}</span>`;
      if (string) return `<span class="token-string">${string}</span>`;
      if (keyword) {
        const functionWords = ['mean', 'max', 'sum', 'ggplot', 'aes', 'geom_line', 'scale_y_continuous', 'labs', 'read_csv', 'tibble', 'source', 'print'];
        return `<span class="${functionWords.includes(keyword) ? 'token-function' : 'token-keyword'}">${keyword}</span>`;
      }
      if (number) return `<span class="token-number">${number}</span>`;
      return `<span class="token-operator">${operator}</span>`;
    },
  );
}

function App() {
  const [scripts, setScripts] = useState<Script[]>(initialScripts);
  const [activeId, setActiveId] = useState('weekly-rides');
  const [openTabs, setOpenTabs] = useState(['weekly-rides']);
  const [code, setCode] = useState(starterScript);
  const [consoleLines, setConsoleLines] = useState(initialConsole);
  const [running, setRunning] = useState(false);
  const [dark, setDark] = useState(false);
  const [insightTab, setInsightTab] = useState<'data' | 'plot'>('data');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [notice, setNotice] = useState('Ready');

  const activeScript = scripts.find((script) => script.id === activeId) ?? scripts[0];
  const highlightedCode = useMemo(() => highlightR(code), [code]);
  const lineCount = Math.max(code.split('\n').length, 1);
  const isDirty = activeScript?.content !== code;

  const chooseScript = (id: string) => {
    const next = scripts.find((script) => script.id === id);
    if (!next) return;
    setScripts((current) => current.map((script) => script.id === activeId ? { ...script, content: code } : script));
    setActiveId(id);
    setCode(next.content);
    if (!openTabs.includes(id)) setOpenTabs((current) => [...current, id]);
    setNotice(`Opened ${next.name}`);
    setSidebarOpen(false);
  };

  const closeTab = (id: string) => {
    if (openTabs.length === 1) return;
    const remaining = openTabs.filter((tabId) => tabId !== id);
    setOpenTabs(remaining);
    if (id === activeId) {
      const nextId = remaining[remaining.length - 1];
      const next = scripts.find((script) => script.id === nextId);
      if (next) {
        setActiveId(nextId);
        setCode(next.content);
      }
    }
  };

  const createScript = () => {
    const id = `script-${Date.now()}`;
    const newScript: Script = {
      id,
      name: `untitled_${scripts.length}.R`,
      size: 'new file',
      type: 'r',
      content: '# Start with a question\\n\\n',
    };
    setScripts((current) => [...current, newScript]);
    setOpenTabs((current) => [...current, id]);
    setActiveId(id);
    setCode(newScript.content);
    setNotice('New R script created');
    setSidebarOpen(false);
  };

  const runScript = () => {
    if (running) return;
    setScripts((current) => current.map((script) => script.id === activeId ? { ...script, content: code } : script));
    setRunning(true);
    setNotice('Running script…');
    window.setTimeout(() => {
      const fileName = activeScript?.name ?? 'script.R';
      const hasPlot = code.includes('ggplot');
      setConsoleLines([
        { text: `> source("${fileName}")`, kind: 'command' },
        { text: code.includes('read_csv') ? 'Rows: 1,248  |  Columns: 5' : 'A tibble: 4 × 2', kind: 'dim' },
        { text: hasPlot ? 'OK  weekly_summary created — 24 observations' : 'OK  Summary calculated — 2 values returned', kind: 'info' },
        { text: hasPlot ? 'OK  Plot rendered in 0.42s' : 'OK  No visual output in this script', kind: 'info' },
        { text: '> ', kind: 'command' },
      ]);
      setRunning(false);
      setNotice(`Finished in ${hasPlot ? '0.42' : '0.18'}s`);
    }, 550);
  };

  const saveBeforeSwitch = (nextCode: string) => {
    setCode(nextCode);
    setNotice('Unsaved changes');
  };

  return (
    <div className={`app-shell ${dark ? 'dark' : ''}`}>
      <header className="app-header">
        <button className="header-icon mobile-menu" aria-label="Open project navigation" data-testid="button-open-sidebar" onClick={() => setSidebarOpen((open) => !open)}>
          <Menu size={17} />
        </button>
        <div className="brand-mark">R</div>
        <div className="brand-name">R Studio</div>
        <div className="brand-caption">browser workbench</div>
        <div className="header-spacer" />
        <button className="header-search" data-testid="button-search">
          <Search size={14} />
          <span>Search project</span>
              <span className="shortcut">Ctrl K</span>
        </button>
        <button className="header-icon" aria-label="Help and documentation" data-testid="button-help"><CircleHelp size={16} /></button>
        <button className="header-icon" aria-label="Toggle color mode" data-testid="button-toggle-theme" onClick={() => setDark((current) => !current)}>
          {dark ? <Sun size={16} /> : <Moon size={16} />}
        </button>
        <div className="avatar" data-testid="text-user-avatar">AL</div>
      </header>

      <div className="workspace">
        <aside className={`sidebar ${sidebarOpen ? 'mobile-visible' : ''}`}>
          <div className="project-switcher">
            <div className="project-glyph"><FolderOpen size={15} /></div>
            <div>
              <div className="project-name">Urban mobility study</div>
              <div className="project-path">~/projects/urban-mobility</div>
            </div>
            <ChevronDown size={14} style={{ marginLeft: 'auto', color: 'hsl(215 14% 60%)' }} />
          </div>

          <div className="sidebar-section-title">
            <span>Project files</span>
            <button aria-label="Create new script" data-testid="button-create-script" onClick={createScript}><Plus size={14} /></button>
          </div>
          <div className="file-list">
            {scripts.map((script) => (
              <button className={`file-row ${script.id === activeId ? 'active' : ''}`} key={script.id} data-testid={`button-file-${script.id}`} onClick={() => chooseScript(script.id)}>
                {script.type === 'r' ? <FileCode2 size={14} /> : <Code2 size={14} />}
                <span>{script.name}</span>
                <span className="file-meta">{script.size}</span>
              </button>
            ))}
          </div>

          <div className="sidebar-section-title"><span>Workspace</span><MoreHorizontal size={14} /></div>
          <nav className="sidebar-nav">
            <button className="nav-row" data-testid="button-workspace-data"><Database size={14} /> Data viewer <ChevronRight size={13} style={{ marginLeft: 'auto' }} /></button>
            <button className="nav-row" data-testid="button-workspace-plots"><BarChart3 size={14} /> Plots <span style={{ marginLeft: 'auto', fontFamily: 'var(--app-font-mono)', fontSize: 10 }}>1</span></button>
            <button className="nav-row" data-testid="button-workspace-packages"><GitBranch size={14} /> Packages</button>
          </nav>

          <div className="sidebar-bottom">
            <div><span className="online-dot" />R session connected</div>
            <div style={{ marginTop: 7, fontFamily: 'var(--app-font-mono)', fontSize: 10 }}>R 4.3.2 · tidyverse 2.0.0</div>
          </div>
        </aside>

        <main className="main-workbench">
          <div className="workbench-toolbar">
            <div className="breadcrumb"><PanelLeft size={14} /><span>Projects</span><ChevronRight size={13} /><strong>urban-mobility</strong></div>
            <div className="toolbar-spacer" />
            <span className="status-copy" data-testid="status-workbench">{notice}</span>
            <button className="toolbar-button" aria-label="Reset workspace" data-testid="button-reset-workspace" onClick={() => { setConsoleLines(initialConsole); setNotice('Console reset'); }}><RotateCcw size={13} /><span>Reset</span></button>
            <button className="run-button" data-testid="button-run-script" onClick={runScript} disabled={running}>
              <Play size={13} fill="currentColor" className={running ? 'running' : ''} />
              {running ? 'Running' : 'Run'}
            </button>
          </div>

          <div className="tabs" role="tablist">
            {openTabs.map((tabId) => {
              const tab = scripts.find((script) => script.id === tabId);
              if (!tab) return null;
              return (
                <button className={`tab ${tabId === activeId ? 'active' : ''}`} key={tabId} role="tab" data-testid={`button-tab-${tabId}`} onClick={() => chooseScript(tabId)}>
                  <FileCode2 size={13} />
                  <span style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>{tab.name}</span>
                  {tabId === activeId && isDirty && <span className="dirty-dot" />}
                  {openTabs.length > 1 && <span className="tab-close" data-testid={`button-close-tab-${tabId}`} onClick={(event) => { event.stopPropagation(); closeTab(tabId); }}><X size={12} /></span>}
                </button>
              );
            })}
            <button className="icon-button" aria-label="New tab" data-testid="button-new-tab" onClick={createScript}><FilePlus2 size={14} /></button>
          </div>

          <div className="split-area">
            <section className="editor-column">
              <div className="editor-header">
                <Code2 size={14} />
                <strong>{activeScript?.name ?? 'untitled.R'}</strong>
                <span>{isDirty ? '· unsaved' : '· saved locally'}</span>
                <div className="editor-tools">
                  <button className="mini-tool" aria-label="Copy code" data-testid="button-copy-code" onClick={() => { void navigator.clipboard?.writeText(code); setNotice('Code copied'); }}><Copy size={13} /></button>
                  <button className="mini-tool" aria-label="Editor settings" data-testid="button-editor-settings"><Settings2 size={13} /></button>
                </div>
              </div>
              <div className="editor-wrap">
                <div className="line-numbers" aria-hidden="true">
                  {Array.from({ length: lineCount }, (_, index) => <div className={index === 0 ? 'active-line' : ''} key={index}>{index + 1}</div>)}
                </div>
                <div className="code-pane">
                  <pre className="code-highlight" aria-hidden="true" dangerouslySetInnerHTML={{ __html: highlightedCode + (code.endsWith('\n') ? '\n' : '') }} />
                  <textarea
                    className="code-input"
                    aria-label="R code editor"
                    data-testid="input-code-editor"
                    spellCheck={false}
                    value={code}
                    onChange={(event) => saveBeforeSwitch(event.target.value)}
                    onKeyDown={(event) => {
                      if (event.key === 'Tab') {
                        event.preventDefault();
                        const start = event.currentTarget.selectionStart;
                        const end = event.currentTarget.selectionEnd;
                        const next = `${code.substring(0, start)}  ${code.substring(end)}`;
                        setCode(next);
                        requestAnimationFrame(() => { event.currentTarget.selectionStart = event.currentTarget.selectionEnd = start + 2; });
                      }
                      if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
                        event.preventDefault();
                        runScript();
                      }
                    }}
                  />
                </div>
              </div>
              <div className="editor-footer"><span>R</span><span>UTF-8</span><span>Spaces: 2</span><span>Ln 1, Col 1</span></div>
            </section>

            <section className="insights-column">
              <div className="insight-tabs">
                <button className={`insight-tab ${insightTab === 'data' ? 'active' : ''}`} data-testid="button-insight-data" onClick={() => setInsightTab('data')}><Table2 size={13} /> Data</button>
                <button className={`insight-tab ${insightTab === 'plot' ? 'active' : ''}`} data-testid="button-insight-plot" onClick={() => setInsightTab('plot')}><BarChart3 size={13} /> Plot</button>
                <button className="insight-tab" data-testid="button-insight-environment" onClick={() => setNotice('Environment is up to date')}><Gauge size={13} /> Environment</button>
              </div>
              <div className="insight-body">
                {insightTab === 'data' ? (
                  <>
                    <div className="data-heading">
                      <div><div className="eyebrow">Preview · rides</div><div className="data-title" data-testid="text-data-title">weekly_summary</div></div>
                      <span className="badge"><Database size={11} /> 24 × 3</span>
                    </div>
                    <div className="table-card" data-testid="table-data-preview">
                      <div className="table-toolbar"><strong>First 5 rows</strong><span>tibble</span></div>
                      <div className="table-scroll"><table><thead><tr><th>week</th><th>member_type</th><th>rides</th></tr></thead><tbody>
                        {[['Jan 08', 'member', '18,432'], ['Jan 08', 'casual', '7,108'], ['Jan 15', 'member', '20,915'], ['Jan 15', 'casual', '8,742'], ['Jan 22', 'member', '19,688']].map((row) => <tr key={`${row[0]}-${row[1]}`}><td>{row[0]}</td><td>{row[1]}</td><td>{row[2]}</td></tr>)}
                      </tbody></table></div>
                    </div>
                    <div className="eyebrow" style={{ marginBottom: 8 }}>Quick read</div>
                    <div className="stats-row">
                      <div className="stat-card"><div className="stat-label">Total rides</div><div className="stat-value" data-testid="text-total-rides">412,846</div><div className="stat-trend">+12.4% vs last month</div></div>
                      <div className="stat-card"><div className="stat-label">Avg. duration</div><div className="stat-value">14.8 min</div><div className="stat-trend">+1.2 min trend</div></div>
                    </div>
                    <div className="tip-card"><div className="eyebrow"><Lightbulb size={11} style={{ verticalAlign: -2, marginRight: 5 }} /> Learning note</div><p>Grouping before summarising gives one row per week and membership type. Try adding <code>weather</code> to the group and run again.</p></div>
                  </>
                ) : (
                  <>
                    <div className="data-heading"><div><div className="eyebrow">Output · ggplot</div><div className="data-title">Weekly rides</div></div><span className="badge"><BarChart3 size={11} /> rendered</span></div>
                    <div className="plot-card" data-testid="plot-preview">
                      <div className="plot-head"><strong>Rides over time</strong><span>member · casual</span></div>
                      <svg className="plot-svg" viewBox="0 0 320 125" role="img" aria-label="Line chart showing weekly rides">
                        <line className="plot-grid" x1="32" x2="307" y1="18" y2="18" /><line className="plot-grid" x1="32" x2="307" y1="58" y2="58" /><line className="plot-grid" x1="32" x2="307" y1="98" y2="98" />
                        <text className="plot-label" x="2" y="21">24k</text><text className="plot-label" x="2" y="61">16k</text><text className="plot-label" x="2" y="101">8k</text>
                        <path className="plot-area" d="M32 91 L71 77 L110 83 L149 59 L188 65 L227 42 L266 48 L307 25 L307 105 L32 105 Z" />
                        <path className="plot-line" d="M32 91 L71 77 L110 83 L149 59 L188 65 L227 42 L266 48 L307 25" />
                        <path className="plot-line" style={{ stroke: 'hsl(var(--accent))' }} d="M32 101 L71 96 L110 92 L149 87 L188 91 L227 74 L266 79 L307 67" />
                        <text className="plot-label" x="29" y="119">Jan 08</text><text className="plot-label" x="142" y="119">Feb 05</text><text className="plot-label" x="267" y="119">Mar 04</text>
                      </svg>
                    </div>
                    <div className="tip-card"><div className="eyebrow"><Info size={11} style={{ verticalAlign: -2, marginRight: 5 }} /> Plot hint</div><p>Two lines, one story: member rides stay steadier while casual rides respond more to the weather.</p></div>
                  </>
                )}
              </div>
            </section>
          </div>

          <section className="console">
            <div className="console-header"><Terminal size={14} color="hsl(177 58% 69%)" /><strong>Console</strong><span className="console-prompt">R session</span><div style={{ marginLeft: 'auto', color: 'hsl(215 14% 58%)', fontSize: 10 }}>connected</div><button className="icon-button" aria-label="Clear console" data-testid="button-clear-console" onClick={() => { setConsoleLines([]); setNotice('Console cleared'); }}><Trash2 size={13} /></button></div>
            <div className="console-output" data-testid="console-output">
              {consoleLines.length ? consoleLines.map((line, index) => <div className={`console-line ${line.kind}`} key={`${line.text}-${index}`}>{line.text}</div>) : <div className="empty-console"><Terminal size={13} /> Run a script to see output here.</div>}
            </div>
          </section>
        </main>
      </div>
    </div>
  );
}

export default App;