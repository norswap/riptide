import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Cards } from "./pages/cards";
import { Home } from "./pages/home";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/cards" element={<Cards />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
