import { useState } from "react";
import { Check, Copy, Info } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const sections = [
  { index: "01", title: "Summary" },
  { index: "02", title: "Numbers" },
  { index: "03", title: "Comparison" },
  { index: "04", title: "Example" },
  { index: "05", title: "Next actions" },
];

function CopyButton({ value }: { value: string }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    await navigator.clipboard.writeText(value);
    setCopied(true);
    setTimeout(() => setCopied(false), 1200);
  }

  return (
    <Button
      variant="ghost"
      size="sm"
      onClick={copy}
      aria-label="Copy command"
      className="h-7 gap-1.5 px-2 text-xs text-muted-foreground"
    >
      {copied ? <Check className="size-3.5" /> : <Copy className="size-3.5" />}
      {copied ? "Copied" : "Copy"}
    </Button>
  );
}

function SectionHeading({ index, title }: { index: string; title: string }) {
  return (
    <div className="mb-5 flex items-baseline gap-3">
      <span className="font-mono text-xs text-muted-foreground">{index}</span>
      <h2 className="text-xl font-semibold tracking-tight">{title}</h2>
    </div>
  );
}

function CodeBlock({ language, code }: { language: string; code: string }) {
  return (
    <div className="overflow-hidden rounded-lg border border-border">
      <div className="flex items-center justify-between border-b border-border bg-muted/40 px-3 py-1.5">
        <span className="font-mono text-[11px] uppercase tracking-wider text-muted-foreground">
          {language}
        </span>
        <CopyButton value={code} />
      </div>
      <pre className="overflow-x-auto bg-muted/20 p-4 font-mono text-sm leading-6">
        <code>{code}</code>
      </pre>
    </div>
  );
}

export default function App() {
  return (
    <main className="mx-auto w-full max-w-5xl px-6 py-10 md:py-14">
      <header>
        <p className="mb-3 font-mono text-xs uppercase tracking-wider text-muted-foreground">
          Explainer
        </p>
        <h1 className="max-w-3xl text-balance text-3xl font-semibold tracking-tight md:text-4xl">
          Replace with a plain, specific title
        </h1>
        <p className="mt-4 max-w-[68ch] text-pretty text-base text-muted-foreground">
          One or two sentences that state what this document answers and why it
          exists. Lead with the conclusion, not the background.
        </p>
        <div className="mt-6 flex flex-wrap gap-2">
          <Badge variant="secondary">scope: example</Badge>
          <Badge variant="secondary">status: draft</Badge>
          <Badge variant="outline">verified</Badge>
        </div>
      </header>

      <section className="mt-10 border-t border-border pt-10">
        <SectionHeading {...sections[0]} />
        <p className="max-w-[68ch] text-sm leading-6 text-muted-foreground">
          A reader who stops after this section should still know the answer, the
          cost, and the next action. Keep it to three sentences.
        </p>
        <div className="mt-5 flex gap-3 rounded-lg border border-border p-4">
          <Info className="mt-0.5 size-4 shrink-0 text-muted-foreground" />
          <div>
            <p className="text-sm font-medium">Key point</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Use a callout for one idea only. If it needs three sentences, it
              belongs in the body.
            </p>
          </div>
        </div>
      </section>

      <section className="mt-10 border-t border-border pt-10">
        <SectionHeading {...sections[1]} />
        <div className="grid gap-4 sm:grid-cols-3">
          {[
            { value: "4 MiB", label: "Default upload limit" },
            { value: "50", label: "Pages per folder" },
            { value: "1", label: "HTML file" },
          ].map((stat) => (
            <Card key={stat.label}>
              <CardContent className="p-5">
                <div className="font-mono text-2xl tabular-nums tracking-tight">
                  {stat.value}
                </div>
                <div className="mt-1 text-xs text-muted-foreground">
                  {stat.label}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </section>

      <section className="mt-10 border-t border-border pt-10">
        <SectionHeading {...sections[2]} />
        <div className="overflow-x-auto rounded-lg border border-border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Option</TableHead>
                <TableHead>When it fits</TableHead>
                <TableHead className="text-right">Cost</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow>
                <TableCell className="font-medium">Single file</TableCell>
                <TableCell className="text-muted-foreground">
                  Shared, offline-readable documents
                </TableCell>
                <TableCell className="text-right font-mono tabular-nums text-muted-foreground">
                  low
                </TableCell>
              </TableRow>
              <TableRow>
                <TableCell className="font-medium">Folder</TableCell>
                <TableCell className="text-muted-foreground">
                  Linked pages with shared assets
                </TableCell>
                <TableCell className="text-right font-mono tabular-nums text-muted-foreground">
                  medium
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </section>

      <section className="mt-10 border-t border-border pt-10">
        <SectionHeading {...sections[3]} />
        <CodeBlock language="sh" code="npx postplan upload ./bundle.html" />
        <Accordion type="single" collapsible className="mt-5">
          <AccordionItem value="detail">
            <AccordionTrigger className="text-sm">
              Deeper detail that most readers do not need
            </AccordionTrigger>
            <AccordionContent className="text-sm text-muted-foreground">
              Progressive disclosure keeps the top scannable. Use one accordion
              per optional deep dive.
            </AccordionContent>
          </AccordionItem>
        </Accordion>
      </section>

      <section className="mt-10 border-t border-border pt-10">
        <SectionHeading {...sections[4]} />
        <ol className="space-y-4">
          {[
            ["State the action", "One line of context, then stop."],
            ["Name the owner", "Or the trigger that starts it."],
            ["Define done", "What evidence closes it."],
          ].map(([title, detail], index) => (
            <li key={title} className="flex gap-3">
              <span className="mt-0.5 grid size-6 shrink-0 place-items-center rounded-full border border-border font-mono text-xs text-muted-foreground">
                {index + 1}
              </span>
              <div>
                <p className="text-sm font-medium">{title}</p>
                <p className="text-sm text-muted-foreground">{detail}</p>
              </div>
            </li>
          ))}
        </ol>
      </section>

      <Separator className="mt-10" />
      <footer className="flex flex-wrap justify-between gap-2 py-6 text-xs text-muted-foreground">
        <span>Generated 2026-11-02</span>
        <span className="font-mono">artifacts skill</span>
      </footer>
    </main>
  );
}
