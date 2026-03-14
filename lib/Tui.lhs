\begin{code}

module Tui (runTui) where

import Brick
import Brick.Widgets.Border
import Brick.Widgets.Border.Style
import qualified Graphics.Vty as V

import Parser (parseQuery)

\end{code}

We use two named viewports so that brick can track their scroll positions
independently.

\begin{code}

data Name = ClausesVP | HistoryVP
  deriving (Eq, Ord, Show)

\end{code}

The state of our TUI: the loaded file contents, the query history, and
whatever the user is currently typing.

\begin{code}

data TuiState = TuiState
  { clausesText :: String
  , history     :: [String]
  , inputBuf    :: String
  }

\end{code}

\subsection{Rendering}

We draw two bordered panes stacked on top of each other.

\begin{code}

drawClausesPane :: TuiState -> Widget Name
drawClausesPane s =
  let content = if null (clausesText s)
                then str "(no file loaded)"
                else str (clausesText s)
  in withBorderStyle unicodeBold
     (borderWithLabel (str "[ Loaded Clauses ]")
     (viewport ClausesVP Vertical content))

drawQueryPane :: TuiState -> Widget Name
drawQueryPane s =
  let histWidgets = if null (history s)
                    then [str "(no queries yet)"]
                    else map str (history s)
      inputLine   = str "?- " <+> str (inputBuf s) <+> str "\9646"
  in withBorderStyle unicodeBold
     (borderWithLabel (str "[ Query ]")
     (vBox [viewport HistoryVP Vertical (vBox histWidgets), hBorder, inputLine]))

drawUI :: TuiState -> [Widget Name]
drawUI s = [vBox [vLimitPercent 40 (drawClausesPane s), drawQueryPane s]]

\end{code}

\subsection{Event handling}

\begin{code}

addDot :: String -> String
addDot q = if null q || last q == '.' then q else q ++ "."

handleEvent :: BrickEvent Name () -> EventM Name TuiState ()

-- quit on Esc or Ctrl-C
handleEvent (VtyEvent (V.EvKey V.KEsc [])) = halt
handleEvent (VtyEvent (V.EvKey (V.KChar 'c') [V.MCtrl])) = halt

-- submit query on Enter: parse and show the resulting [Term]
handleEvent (VtyEvent (V.EvKey V.KEnter [])) = do
  s <- get
  let q      = addDot (inputBuf s)
      result = case parseQuery q of
                 Left err    -> "Parse error: " ++ show err
                 Right terms -> show terms
      newLines = ["?- " ++ q, result, ""]
  modify (\st -> st { history = history st ++ newLines, inputBuf = "" })
  vScrollToEnd (viewportScroll HistoryVP)

-- backspace to delete character
handleEvent (VtyEvent (V.EvKey V.KBS [])) = do
  s <- get
  let buf = inputBuf s
  if null buf
    then return ()
    else modify (\st -> st { inputBuf = init buf })

-- typing characters
handleEvent (VtyEvent (V.EvKey (V.KChar c) [])) =
  modify (\s -> s { inputBuf = inputBuf s ++ [c] })

-- scroll the clauses pane
handleEvent (VtyEvent (V.EvKey V.KUp [])) =
  vScrollBy (viewportScroll ClausesVP) (-1)
handleEvent (VtyEvent (V.EvKey V.KDown [])) =
  vScrollBy (viewportScroll ClausesVP) 1

-- ignore everything else
handleEvent _ = return ()

\end{code}

\subsection{App definition}

\begin{code}

tuiApp :: App TuiState () Name
tuiApp = App
  { appDraw         = drawUI
  , appChooseCursor = showFirstCursor
  , appHandleEvent  = handleEvent
  , appStartEvent   = return ()
  , appAttrMap      = const (attrMap V.defAttr [])
  }

\end{code}

\subsection{Entry point}

\begin{code}

runTui :: String -> IO ()
runTui clauses = do
  let initState = TuiState
        { clausesText = clauses
        , history     = []
        , inputBuf    = ""
        }
  _ <- defaultMain tuiApp initState
  return ()

\end{code}