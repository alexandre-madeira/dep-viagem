import { useState, useEffect, useCallback } from "react";

// ─────────────────────────────────────────────────────────────
// CONFIGURAÇÃO — ajuste para seu ambiente
// ─────────────────────────────────────────────────────────────
const CONFIG = {
  API_BASE: "https://webhook.solucaomadeira.com/webhook/dpv-financeiro",
  // Troque pela URL do seu n8n se for diferente
};

const CATEGORIAS = [
  { key: "todos",       label: "Todas",       icon: "◈",  color: "#94A3B8" },
  { key: "alimentacao", label: "Alimentação", icon: "🍽️", color: "#F59E0B" },
  { key: "combustivel", label: "Combustível", icon: "⛽", color: "#EF4444" },
  { key: "hospedagem",  label: "Hospedagem",  icon: "🏨", color: "#8B5CF6" },
  { key: "transporte",  label: "Transporte",  icon: "🚗", color: "#3B82F6" },
  { key: "pedagio",     label: "Pedágio",     icon: "🛣️", color: "#10B981" },
  { key: "outros",      label: "Outros",      icon: "📦", color: "#6B7280" },
];

const STATUS = {
  ativa:     { bg:"#022c22", border:"#065f46", text:"#6ee7b7", label:"Em andamento", dot:"#34d399" },
  encerrada: { bg:"#1e1b4b", border:"#3730a3", text:"#a5b4fc", label:"Encerrada",    dot:"#818cf8" },
  aprovada:  { bg:"#052e16", border:"#166534", text:"#86efac", label:"Aprovada ✓",   dot:"#4ade80" },
};

const fmt   = (v) => `R$ ${parseFloat(v||0).toFixed(2).replace(".",",")}`;
const fmtDt = (d) => d ? new Date(d).toLocaleDateString("pt-BR",{day:"2-digit",month:"short",year:"numeric"}) : "—";
const catOf = (k) => CATEGORIAS.find(c=>c.key===k) || CATEGORIAS[6];

// ─── Login ────────────────────────────────────────────────────
function Login({ onAuth }) {
  const [pw, setPw]     = useState("");
  const [err, setErr]   = useState(false);
  const [load, setLoad] = useState(false);

  const tentar = async () => {
    if (!pw.trim()) return;
    setLoad(true); setErr(false);
    try {
      const r = await fetch(CONFIG.API_BASE, {
        method:"POST",
        headers:{"Content-Type":"application/json"},
        body: JSON.stringify({ acao: "auth", senha: pw }),
      });
      const d = await r.json();
      if (d.ok) { onAuth(pw); return; }
      setErr(true);
    } catch {
      // fallback demo
      if (pw === "SENHA_CONFIGURADA_NO_N8N") { onAuth(pw); return; }
      setErr(true);
    }
    setLoad(false);
    setTimeout(() => setErr(false), 2000);
  };

  return (
    <div style={{
      minHeight:"100vh", background:"#020617",
      display:"flex", alignItems:"center", justifyContent:"center",
      fontFamily:"'Inter',system-ui,sans-serif"
    }}>
      <div style={{
        position:"fixed", top:"30%", left:"50%",
        transform:"translate(-50%,-50%)",
        width:500, height:300, borderRadius:"50%",
        background:"radial-gradient(ellipse,rgba(99,102,241,.15) 0%,transparent 70%)",
        pointerEvents:"none"
      }}/>
      <div style={{
        background:"#0f172a", border:"1px solid #1e293b",
        borderRadius:20, padding:"44px 40px", width:360,
        boxShadow:"0 32px 64px rgba(0,0,0,.6)", position:"relative", zIndex:1
      }}>
        <div style={{ textAlign:"center", marginBottom:32 }}>
          <div style={{
            width:52, height:52, margin:"0 auto 14px",
            background:"linear-gradient(135deg,#4f46e5,#7c3aed)",
            borderRadius:14, display:"flex", alignItems:"center",
            justifyContent:"center", fontSize:24,
            boxShadow:"0 8px 24px rgba(99,102,241,.4)"
          }}>💼</div>
          <div style={{ color:"#f1f5f9", fontWeight:800, fontSize:20 }}>Painel Financeiro</div>
          <div style={{ color:"#475569", fontSize:12, marginTop:4 }}>dep-viagem · Prestação de Contas</div>
        </div>

        <div style={{ marginBottom:14 }}>
          <div style={{ color:"#64748b", fontSize:11, fontWeight:700, letterSpacing:"0.08em", marginBottom:7 }}>
            SENHA DE ACESSO
          </div>
          <input
            type="password" value={pw}
            onChange={e=>{ setPw(e.target.value); setErr(false); }}
            onKeyDown={e=>e.key==="Enter"&&tentar()}
            placeholder="••••••••"
            style={{
              width:"100%", padding:"11px 13px", borderRadius:10,
              background:"#020617",
              border:`1.5px solid ${err?"#ef4444":"#1e293b"}`,
              color:"#f1f5f9", fontSize:15, outline:"none", boxSizing:"border-box",
              boxShadow: err?"0 0 0 3px rgba(239,68,68,.15)":"none"
            }}
          />
          {err && <div style={{ color:"#f87171", fontSize:12, marginTop:5 }}>Senha incorreta.</div>}
        </div>
        <button onClick={tentar} disabled={load} style={{
          width:"100%", padding:"12px", borderRadius:10, border:"none",
          background: load ? "#1e293b" : "linear-gradient(135deg,#4f46e5,#7c3aed)",
          color:"#fff", fontWeight:700, fontSize:14, cursor:load?"default":"pointer",
          boxShadow:"0 4px 16px rgba(99,102,241,.4)"
        }}>{load ? "Verificando..." : "Entrar"}</button>
      </div>
    </div>
  );
}

// ─── Barras por categoria ─────────────────────────────────────
function CatBars({ despesas }) {
  const totais = CATEGORIAS.slice(1)
    .map(c=>({ ...c, v: despesas.filter(d=>d.categoria===c.key).reduce((s,d)=>s+parseFloat(d.valor_total),0) }))
    .filter(c=>c.v>0).sort((a,b)=>b.v-a.v);
  const max = totais[0]?.v || 1;
  return (
    <div style={{ display:"flex", flexDirection:"column", gap:7 }}>
      {totais.map(c=>(
        <div key={c.key} style={{ display:"flex", alignItems:"center", gap:10 }}>
          <span style={{ fontSize:13, width:18 }}>{c.icon}</span>
          <span style={{ color:"#64748b", fontSize:11, width:82, flexShrink:0 }}>{c.label}</span>
          <div style={{ flex:1, background:"#0f172a", borderRadius:99, height:6, overflow:"hidden" }}>
            <div style={{ width:`${(c.v/max)*100}%`, height:"100%", background:c.color, borderRadius:99, transition:"width .7s" }}/>
          </div>
          <span style={{ color:"#e2e8f0", fontSize:11, fontWeight:700, width:82, textAlign:"right" }}>{fmt(c.v)}</span>
        </div>
      ))}
    </div>
  );
}

// ─── Card de viagem ───────────────────────────────────────────
function ViagemCard({ v, senha, onAtualizar }) {
  const [open, setOpen]   = useState(false);
  const [acao, setAcao]   = useState(null);
  const st    = STATUS[v.status] || STATUS.encerrada;
  const total = (v.despesas||[]).reduce((s,d)=>s+parseFloat(d.valor_total||0),0);

  const executar = async (tipo) => {
    setAcao(tipo);
    try {
      const r = await fetch(CONFIG.API_BASE, {
        method:"POST",
        headers:{"Content-Type":"application/json"},
        body: JSON.stringify({ acao: tipo, viagem_id: v.id, phone: v.phone, senha }),
      });
      if (tipo==="zip-nfs") {
        const blob = await r.blob();
        const url  = URL.createObjectURL(blob);
        const a    = document.createElement("a");
        a.href     = url;
        a.download = `NFs_${v.nome_viagem||v.id}.zip`;
        a.click();
      } else if (tipo==="relatorio-pdf") {
        const blob = await r.blob();
        window.open(URL.createObjectURL(blob), "_blank");
      } else if (tipo==="aprovar") {
        onAtualizar();
      }
    } catch { alert("Erro ao executar. Verifique a conexão com o n8n."); }
    setAcao(null);
  };

  return (
    <div style={{
      background:"#0f172a", borderRadius:16,
      border:`1px solid ${open?"#334155":"#1e293b"}`,
      overflow:"hidden"
    }}>
      <div onClick={()=>setOpen(!open)} style={{
        padding:"18px 20px", cursor:"pointer",
        display:"flex", alignItems:"center", gap:14
      }}>
        <div style={{
          width:44, height:44, borderRadius:12, flexShrink:0,
          background:"linear-gradient(135deg,#1d4ed8,#6d28d9)",
          display:"flex", alignItems:"center", justifyContent:"center", fontSize:20
        }}>🧳</div>
        <div style={{ flex:1, minWidth:0 }}>
          <div style={{ display:"flex", alignItems:"center", gap:8, flexWrap:"wrap" }}>
            <span style={{ color:"#f1f5f9", fontWeight:700, fontSize:15 }}>{v.nome_viagem || "Viagem"}</span>
            <span style={{
              background:st.bg, border:`1px solid ${st.border}`,
              color:st.text, fontSize:10, fontWeight:700,
              padding:"2px 8px", borderRadius:99,
              display:"flex", alignItems:"center", gap:4
            }}>
              <span style={{ width:5, height:5, borderRadius:"50%", background:st.dot, display:"inline-block" }}/>
              {st.label.toUpperCase()}
            </span>
          </div>
          <div style={{ color:"#475569", fontSize:12, marginTop:3 }}>
            {v.funcionario_nome || v.phone} · {fmtDt(v.data_inicio)}
            {v.data_fim ? ` → ${fmtDt(v.data_fim)}` : " · em andamento"}
          </div>
        </div>
        <div style={{ textAlign:"right", flexShrink:0 }}>
          <div style={{ color:"#f1f5f9", fontWeight:800, fontSize:19 }}>{fmt(total)}</div>
          <div style={{ color:"#475569", fontSize:11 }}>{(v.despesas||[]).length} nota{(v.despesas||[]).length!==1?"s":""}</div>
        </div>
        <div style={{ color:"#334155", fontSize:18, transition:"transform .2s", transform:open?"rotate(180deg)":"none" }}>⌄</div>
      </div>

      {open && (
        <div style={{ borderTop:"1px solid #1e293b" }}>
          {(v.despesas||[]).length > 0 && (
            <div style={{ padding:"16px 20px", borderBottom:"1px solid #1e293b" }}>
              <div style={{ color:"#334155", fontSize:10, fontWeight:700, letterSpacing:"0.1em", marginBottom:12 }}>
                DISTRIBUIÇÃO POR CATEGORIA
              </div>
              <CatBars despesas={v.despesas||[]} />
            </div>
          )}

          <div style={{ padding:"16px 20px" }}>
            <div style={{ color:"#334155", fontSize:10, fontWeight:700, letterSpacing:"0.1em", marginBottom:12 }}>
              NOTAS FISCAIS — EM ORDEM CRONOLÓGICA
            </div>
            <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
              {[...(v.despesas||[])].sort((a,b)=>new Date(a.data_emissao)-new Date(b.data_emissao))
                .map((d,i)=>{
                  const cat = catOf(d.categoria);
                  return (
                    <div key={d.id||i} style={{
                      display:"flex", alignItems:"center", gap:10,
                      background:"#020617", borderRadius:10, padding:"10px 13px"
                    }}>
                      <div style={{
                        width:22, height:22, borderRadius:6, flexShrink:0,
                        background:"#0f172a", border:"1px solid #1e293b",
                        display:"flex", alignItems:"center", justifyContent:"center",
                        color:"#334155", fontSize:10, fontWeight:700
                      }}>{String(i+1).padStart(2,"0")}</div>
                      <span style={{ fontSize:15 }}>{cat.icon}</span>
                      <div style={{ flex:1, minWidth:0 }}>
                        <div style={{ color:"#e2e8f0", fontSize:13, fontWeight:600,
                          overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap" }}>
                          {d.estabelecimento}
                        </div>
                        <div style={{ color:"#475569", fontSize:11, marginTop:1 }}>
                          <span style={{ color:cat.color }}>{cat.label}</span>
                          {" · "}{fmtDt(d.data_emissao)}
                          {d.cnpj && <span style={{ color:"#334155" }}>{" · "}{d.cnpj}</span>}
                        </div>
                      </div>
                      <span style={{ color:"#f1f5f9", fontWeight:800, fontSize:14, flexShrink:0 }}>{fmt(d.valor_total)}</span>
                    </div>
                  );
                })}
            </div>
            <div style={{
              marginTop:10, padding:"12px 13px",
              background:"linear-gradient(135deg,rgba(99,102,241,.08),rgba(124,58,237,.08))",
              border:"1px solid rgba(99,102,241,.2)", borderRadius:10,
              display:"flex", justifyContent:"space-between", alignItems:"center"
            }}>
              <span style={{ color:"#818cf8", fontSize:12, fontWeight:700 }}>TOTAL DA VIAGEM</span>
              <span style={{ color:"#c7d2fe", fontWeight:900, fontSize:17 }}>{fmt(total)}</span>
            </div>
          </div>

          <div style={{ padding:"13px 20px", borderTop:"1px solid #1e293b", display:"flex", gap:8, flexWrap:"wrap" }}>
            {[
              { tipo:"relatorio-pdf", icon:"📄", label:"Relatório PDF", cor:"#3b82f6" },
              { tipo:"zip-nfs",       icon:"🗜️", label:"NFs em ZIP",    cor:"#8b5cf6" },
            ].map(b=>(
              <button key={b.tipo} onClick={()=>executar(b.tipo)} disabled={!!acao} style={{
                display:"flex", alignItems:"center", gap:6,
                padding:"8px 14px", borderRadius:8,
                border:`1.5px solid ${acao?="#1e293b":b.cor+"55"}`,
                background: acao ? "transparent" : b.cor+"11",
                color: acao ? "#334155" : b.cor,
                fontSize:12, fontWeight:700, cursor:acao?"default":"pointer"
              }}>
                <span>{acao===b.tipo?"⏳":b.icon}</span>
                <span>{acao===b.tipo?"Aguarde...":b.label}</span>
              </button>
            ))}
            {v.status==="encerrada" && (
              <button onClick={()=>executar("aprovar")} disabled={!!acao} style={{
                display:"flex", alignItems:"center", gap:6,
                padding:"8px 14px", borderRadius:8,
                border:`1.5px solid ${acao?"#1e293b":"#10b98155"}`,
                background: acao ? "transparent" : "#10b98111",
                color: acao ? "#334155" : "#10b981",
                fontSize:12, fontWeight:700, cursor:acao?"default":"pointer"
              }}>
                <span>{acao==="aprovar"?"⏳":"✅"}</span>
                <span>{acao==="aprovar"?"Aguarde...":"Aprovar prestação"}</span>
              </button>
            )}
            {v.status==="aprovada" && (
              <span style={{ color:"#4ade80", fontSize:12, display:"flex", alignItems:"center", gap:5 }}>
                ✓ Aprovada e arquivada
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Painel principal ─────────────────────────────────────────
function Painel({ senha, onLogout }) {
  const [viagens, setViagens]           = useState([]);
  const [loading, setLoading]           = useState(true);
  const [erro, setErro]                 = useState(null);
  const [tela, setTela]                 = useState("viagens");
  const [busca, setBusca]               = useState("");
  const [filtroStatus, setFiltroStatus] = useState("todos");
  const [filtroCat, setFiltroCat]       = useState("todos");
  const [dataIni, setDataIni]           = useState("");
  const [dataFim, setDataFim]           = useState("");

  const carregar = useCallback(async () => {
    setLoading(true); setErro(null);
    try {
      const r = await fetch(CONFIG.API_BASE, {
        method:"POST",
        headers:{"Content-Type":"application/json"},
        body: JSON.stringify({ acao: "viagens", senha }),
      });
      const d = await r.json();
      setViagens(d.viagens || []);
    } catch { setErro("Não foi possível conectar ao servidor n8n."); }
    setLoading(false);
  }, [senha]);

  useEffect(() => { carregar(); }, [carregar]);

  const filtradas = viagens.filter(v=>{
    if (filtroStatus !== "todos" && v.status !== filtroStatus) return false;
    if (busca && !`${v.funcionario_nome||""} ${v.nome_viagem||""} ${v.phone||""}`
      .toLowerCase().includes(busca.toLowerCase())) return false;
    if (filtroCat !== "todos" && !(v.despesas||[]).some(d=>d.categoria===filtroCat)) return false;
    if (dataIni && new Date(v.data_inicio) < new Date(dataIni)) return false;
    if (dataFim && new Date(v.data_inicio) > new Date(dataFim)) return false;
    return true;
  });

  const totalGeral  = filtradas.reduce((s,v)=>(v.despesas||[]).reduce((ss,d)=>ss+parseFloat(d.valor_total||0),0)+s,0);
  const totalNotas  = filtradas.reduce((s,v)=>s+(v.despesas||[]).length,0);
  const pendAprov   = filtradas.filter(v=>v.status==="encerrada").length;
  const todasDesp   = filtradas.flatMap(v=>v.despesas||[]);
  const resumoCat   = CATEGORIAS.slice(1)
    .map(c=>({ ...c, total: todasDesp.filter(d=>d.categoria===c.key).reduce((s,d)=>s+parseFloat(d.valor_total),0), qtd: todasDesp.filter(d=>d.categoria===c.key).length }))
    .filter(c=>c.total>0).sort((a,b)=>b.total-a.total);

  return (
    <div style={{ minHeight:"100vh", background:"#020617", fontFamily:"'Inter',system-ui,sans-serif", color:"#f1f5f9" }}>
      {/* Navbar */}
      <div style={{
        background:"#0f172a", borderBottom:"1px solid #1e293b",
        padding:"0 20px", height:56,
        display:"flex", alignItems:"center", justifyContent:"space-between",
        position:"sticky", top:0, zIndex:50
      }}>
        <div style={{ display:"flex", alignItems:"center", gap:10 }}>
          <div style={{
            width:30, height:30, borderRadius:8,
            background:"linear-gradient(135deg,#4f46e5,#7c3aed)",
            display:"flex", alignItems:"center", justifyContent:"center", fontSize:15
          }}>💼</div>
          <span style={{ fontWeight:800, fontSize:15 }}>dep-viagem</span>
          <span style={{ color:"#334155", fontSize:13 }}>· Financeiro</span>
        </div>
        <div style={{ display:"flex", gap:4 }}>
          {[["viagens","🗂️ Viagens"],["resumo","📊 Resumo"]].map(([id,lbl])=>(
            <button key={id} onClick={()=>setTela(id)} style={{
              padding:"6px 14px", borderRadius:8, border:"none",
              background: tela===id?"#1e293b":"transparent",
              color: tela===id?"#f1f5f9":"#475569",
              fontSize:13, fontWeight:600, cursor:"pointer"
            }}>{lbl}</button>
          ))}
        </div>
        <div style={{ display:"flex", gap:8, alignItems:"center" }}>
          <button onClick={carregar} style={{
            background:"transparent", border:"1px solid #1e293b",
            color:"#475569", padding:"5px 10px", borderRadius:8, fontSize:12, cursor:"pointer"
          }}>↺</button>
          <button onClick={onLogout} style={{
            background:"transparent", border:"1px solid #1e293b",
            color:"#475569", padding:"5px 12px", borderRadius:8, fontSize:12, cursor:"pointer"
          }}>Sair</button>
        </div>
      </div>

      <div style={{ maxWidth:880, margin:"0 auto", padding:"20px 16px" }}>
        {/* KPIs */}
        <div style={{ display:"grid", gridTemplateColumns:"repeat(4,1fr)", gap:10, marginBottom:20 }}>
          {[
            { label:"Total Filtrado",    value:fmt(totalGeral), icon:"💰", cor:"#6366f1" },
            { label:"Viagens",           value:filtradas.length, icon:"🧳", cor:"#8b5cf6" },
            { label:"Notas Fiscais",     value:totalNotas,       icon:"🧾", cor:"#06b6d4" },
            { label:"Aguard. Aprovação", value:pendAprov,        icon:"⏳", cor:"#f59e0b" },
          ].map(c=>(
            <div key={c.label} style={{
              background:"#0f172a", borderRadius:12, border:"1px solid #1e293b", padding:"14px 16px"
            }}>
              <div style={{ color:"#334155", fontSize:10, fontWeight:700, letterSpacing:"0.08em", marginBottom:8 }}>
                {c.label.toUpperCase()}
              </div>
              <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                <span style={{ fontSize:18 }}>{c.icon}</span>
                <span style={{ fontSize:20, fontWeight:900, color:c.cor }}>{c.value}</span>
              </div>
            </div>
          ))}
        </div>

        {/* ── TELA VIAGENS ── */}
        {tela==="viagens" && (<>
          {/* Filtros */}
          <div style={{ background:"#0f172a", border:"1px solid #1e293b", borderRadius:12, padding:"14px 16px", marginBottom:16 }}>
            <div style={{ color:"#334155", fontSize:10, fontWeight:700, letterSpacing:"0.1em", marginBottom:10 }}>FILTROS</div>
            <div style={{ display:"flex", flexWrap:"wrap", gap:8 }}>
              <input placeholder="🔍 Buscar funcionário ou viagem" value={busca}
                onChange={e=>setBusca(e.target.value)} style={{
                  flex:"1 1 180px", padding:"8px 11px", borderRadius:8,
                  background:"#020617", border:"1px solid #1e293b",
                  color:"#f1f5f9", fontSize:12, outline:"none"
                }}/>
              <select value={filtroStatus} onChange={e=>setFiltroStatus(e.target.value)} style={{
                padding:"8px 11px", borderRadius:8, background:"#020617",
                border:"1px solid #1e293b", color:"#f1f5f9", fontSize:12, outline:"none"
              }}>
                <option value="todos">Todos os status</option>
                <option value="ativa">Em andamento</option>
                <option value="encerrada">Encerradas</option>
                <option value="aprovada">Aprovadas</option>
              </select>
              <select value={filtroCat} onChange={e=>setFiltroCat(e.target.value)} style={{
                padding:"8px 11px", borderRadius:8, background:"#020617",
                border:"1px solid #1e293b", color:"#f1f5f9", fontSize:12, outline:"none"
              }}>
                {CATEGORIAS.map(c=><option key={c.key} value={c.key}>{c.icon} {c.label}</option>)}
              </select>
              <input type="date" value={dataIni} onChange={e=>setDataIni(e.target.value)} style={{
                padding:"8px 11px", borderRadius:8, background:"#020617",
                border:"1px solid #1e293b", color:dataIni?"#f1f5f9":"#475569", fontSize:12, outline:"none"
              }}/>
              <input type="date" value={dataFim} onChange={e=>setDataFim(e.target.value)} style={{
                padding:"8px 11px", borderRadius:8, background:"#020617",
                border:"1px solid #1e293b", color:dataFim?"#f1f5f9":"#475569", fontSize:12, outline:"none"
              }}/>
              {(busca||filtroStatus!=="todos"||filtroCat!=="todos"||dataIni||dataFim) && (
                <button onClick={()=>{setBusca("");setFiltroStatus("todos");setFiltroCat("todos");setDataIni("");setDataFim("");}}
                  style={{ padding:"8px 12px", borderRadius:8, border:"1px solid #334155",
                    background:"transparent", color:"#64748b", fontSize:12, cursor:"pointer" }}>✕ Limpar</button>
              )}
            </div>
          </div>

          {/* Estado de carregamento */}
          {loading && (
            <div style={{ textAlign:"center", padding:"60px 0", color:"#334155" }}>
              <div style={{ fontSize:32, marginBottom:12 }}>⏳</div>Carregando...
            </div>
          )}
          {erro && (
            <div style={{
              background:"#1a0a0a", border:"1px solid #7f1d1d",
              borderRadius:12, padding:"16px 20px", color:"#fca5a5", fontSize:13
            }}>⚠️ {erro}</div>
          )}
          {!loading && !erro && filtradas.length===0 && (
            <div style={{ textAlign:"center", padding:"60px 0", color:"#334155" }}>
              <div style={{ fontSize:40, marginBottom:12 }}>🔍</div>
              Nenhuma viagem encontrada.
            </div>
          )}
          {!loading && !erro && (
            <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
              {filtradas.map(v=>(
                <ViagemCard key={v.id} v={v} senha={senha} onAtualizar={carregar} />
              ))}
            </div>
          )}
        </>)}

        {/* ── TELA RESUMO ── */}
        {tela==="resumo" && (
          <div style={{ display:"flex", flexDirection:"column", gap:14 }}>
            {/* Por categoria */}
            <div style={{ background:"#0f172a", border:"1px solid #1e293b", borderRadius:14, padding:"20px" }}>
              <div style={{ color:"#334155", fontSize:10, fontWeight:700, letterSpacing:"0.1em", marginBottom:18 }}>
                CONSOLIDADO POR CATEGORIA
              </div>
              {resumoCat.length===0
                ? <div style={{ color:"#334155", fontSize:13 }}>Sem dados.</div>
                : resumoCat.map(c=>{
                    const pct = totalGeral>0 ? c.total/totalGeral*100 : 0;
                    return (
                      <div key={c.key} style={{ marginBottom:14 }}>
                        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:6 }}>
                          <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                            <span style={{ fontSize:16 }}>{c.icon}</span>
                            <span style={{ color:"#e2e8f0", fontSize:13, fontWeight:600 }}>{c.label}</span>
                            <span style={{ background:"#1e293b", color:"#64748b", fontSize:10, padding:"1px 7px", borderRadius:99 }}>
                              {c.qtd} nota{c.qtd!==1?"s":""}
                            </span>
                          </div>
                          <div>
                            <span style={{ color:"#f1f5f9", fontWeight:800, fontSize:15 }}>{fmt(c.total)}</span>
                            <span style={{ color:"#475569", fontSize:11, marginLeft:6 }}>{pct.toFixed(1)}%</span>
                          </div>
                        </div>
                        <div style={{ height:8, background:"#0f172a", borderRadius:99, border:"1px solid #1e293b", overflow:"hidden" }}>
                          <div style={{ width:`${pct}%`, height:"100%", background:`linear-gradient(90deg,${c.color}99,${c.color})`, borderRadius:99, transition:"width .8s" }}/>
                        </div>
                      </div>
                    );
                  })
              }
              <div style={{ marginTop:12, paddingTop:14, borderTop:"1px solid #1e293b", display:"flex", justifyContent:"space-between" }}>
                <span style={{ color:"#64748b", fontSize:12 }}>{todasDesp.length} notas · {filtradas.length} viagens</span>
                <span style={{ color:"#c7d2fe", fontWeight:900, fontSize:16 }}>{fmt(totalGeral)}</span>
              </div>
            </div>

            {/* Por funcionário */}
            <div style={{ background:"#0f172a", border:"1px solid #1e293b", borderRadius:14, padding:"20px" }}>
              <div style={{ color:"#334155", fontSize:10, fontWeight:700, letterSpacing:"0.1em", marginBottom:16 }}>
                CONSOLIDADO POR FUNCIONÁRIO
              </div>
              <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
                {filtradas.map(v=>{
                  const tot = (v.despesas||[]).reduce((s,d)=>s+parseFloat(d.valor_total||0),0);
                  const st  = STATUS[v.status]||STATUS.encerrada;
                  return (
                    <div key={v.id} style={{
                      display:"flex", alignItems:"center", gap:12,
                      padding:"12px 14px", background:"#020617", borderRadius:10
                    }}>
                      <div style={{
                        width:36, height:36, borderRadius:10, flexShrink:0,
                        background:"linear-gradient(135deg,#1d4ed8,#6d28d9)",
                        display:"flex", alignItems:"center", justifyContent:"center", fontSize:16
                      }}>🧳</div>
                      <div style={{ flex:1, minWidth:0 }}>
                        <div style={{ color:"#e2e8f0", fontSize:13, fontWeight:700,
                          overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap" }}>
                          {v.funcionario_nome||v.phone}
                        </div>
                        <div style={{ color:"#475569", fontSize:11, marginTop:2 }}>
                          {v.nome_viagem} · {(v.despesas||[]).length} nota{(v.despesas||[]).length!==1?"s":""}
                        </div>
                      </div>
                      <span style={{
                        background:st.bg, border:`1px solid ${st.border}`,
                        color:st.text, fontSize:10, fontWeight:700,
                        padding:"2px 8px", borderRadius:99, flexShrink:0
                      }}>{st.label.toUpperCase()}</span>
                      <span style={{ color:"#f1f5f9", fontWeight:900, fontSize:15, flexShrink:0, marginLeft:4 }}>
                        {fmt(tot)}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── App root ─────────────────────────────────────────────────
export default function App() {
  const [senha, setSenha] = useState(() => sessionStorage.getItem("dpv_auth") || "");
  if (!senha) return <Login onAuth={s=>{ sessionStorage.setItem("dpv_auth",s); setSenha(s); }} />;
  return <Painel senha={senha} onLogout={()=>{ sessionStorage.removeItem("dpv_auth"); setSenha(""); }} />;
}
