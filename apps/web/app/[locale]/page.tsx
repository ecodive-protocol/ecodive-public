import { Navbar } from "@/components/Navbar";
import { Hero } from "@/components/Hero";
import { Tokenomics } from "@/components/Tokenomics";
import { Roadmap } from "@/components/Roadmap";
import { FAQ } from "@/components/FAQ";
import { Newsletter } from "@/components/Newsletter";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
      <div style={{ background: "#040c19" }} className="min-h-screen">
      <Navbar />
      <Hero />
      <Tokenomics />
      <Roadmap />
      <FAQ />
      <Newsletter />
      <Footer />
    </div>
  );
}
