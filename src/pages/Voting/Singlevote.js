import { Card, Button, Container, ProgressBar} from 'react-bootstrap'

const Singlevote = () => {
  return (
    <Container>    
      <Card style={{padding: '4%'}}>
        <div style={{display: 'flex', justifyContent: 'space-between'}}>
          <h2>← All Proposals</h2>
          <Button variant="outline-success">Success</Button>
        </div>
        <Card.Body>
          <h3>Test Proposal</h3>
          <p>Voting ended December 26, 2020, 10:13 PM CST</p>
          <Card body style={{minHeight: '50%', marginBottom: '4%'}}>
            <div style={{display: 'flex', justifyContent: 'space-between', paddingBottom: '4%'}}>
              <h3>For</h3>
              <h3>Vote Count</h3>
            </div>
            <ProgressBar animated now={45} />
          </Card>
          <h4>Details</h4>
          <p>1: UNI.transfer(0x5e14ed9dCeE22ba758E8de482301028b261c4a14, 519500000000000000000000)</p>
          <h4>Description</h4>
          <h4>Test Proposal</h4>
          <p>Author <em>Test</em></p>
          <h4>Summary</h4>
          <p>This post outlines a framework for funding Uniswap ecosystem development with grants from the UNI Community Treasury. 
            The program starts small—sponsoring hackathons, for example—but could grow in significance over time (with renewals 
            approved by governance) to fund core protocol development. Grants administration is a subjective process that cannot 
            be easily automated, and thus we propose a nimble committee of 6 members —1 lead and 5 reviewers—to deliver an efficient, 
            predictable process to applicants, such that funding can be administered without having to put each application to a vote. 
            We propose the program start with an initial cap of $750K per quarter and a limit of 2 quarters before renewal—a sum that 
            we feel is appropriate for an MVP relative to the size of the treasury that UNI token holders are entrusted with allocating.</p>
          <h4>Purpose</h4>
          <p>The mission of the UGP is to provide valuable resources to help grow the Uniswap ecosystem. Through public discourse and 
            inbound applications, the community will get first-hand exposure to identify and respond to the most pressing needs of the 
            ecosystem, as well as the ability to support innovative projects expanding the capabilities of Uniswap. By rewarding talent 
            early with developer incentives, bounties, and infrastructure support, UGP acts as a catalyst for growth and helps to 
            maintain Uniswap as a nexus for DeFi on Ethereum.</p>
            <h4>Quarterly Budget:</h4>
            <ul>
              <li>Max quarterly budget of up to $750k</li>
              <li>Budget and caps to be assessed every six months</li>
            </ul>
            <h4>Grant Allocation Committee:</h4>
            <ul>
              <li>Of 6 committee members: 1 lead and 5 reviewers</li>
              <li>Each committee has a term of 2 quarters (6 months) after which the program needs to be renewed by UNI governance</li>
            </ul>
            <h4>Committee Members</h4>
            <p>The other 5 committee members should be thought of as “reviewers” — UNI community members who will keep the grants program 
              functional by ensuring Ken is leading effectively and, of course, not absconding with funds. Part of the reviewers job is to 
              hold the program accountable for success (defined below) and/or return any excess funds to the UNI treasury. Reviewers are not 
              compensated as part of this proposal as we expect their time commitment to be minimal. Compensation for the lead role is 
              discussed below, as we expect this to be a labor intensive role.</p>
              <h4>Methodology</h4>
              <h5>1.1 Budget</h5>
              <p>This proposal recommends a max cap of $750K per quarter, with the ability to reevaluate biannually at each epoch (two 
                fiscal quarters). While the UGP Grants Committee will be the decision makers around individual grants, respective budgets, 
                roadmaps, and milestones, any top-level changes to UGP including epochs and max cap, will require full community quorum (4% approval).
                The UGP will be funded by the UNI treasury according to the release schedule set out by the Uniswap team, whereby 43% of the UNI 
                treasury is released over a four-year timeline. In Year 1 this will total to 172,000,000 UNI (~$344M as of writing). Taking into 
                consideration the current landscape of ecosystem funding across Ethereum, the community would be hard-pressed to allocate even 5% 
                of Year 1’s treasury. For context Gitcoin CLR Round 7 distributed $725k ($450k in matched) across 857 projects and YTD, Moloch has 
                granted just under $200k but in contrast, the EF has committed to somewhere in the 8 figure range.</p>
                <h5>1.2 Committee Compensation</h5>
                <p>Operating a successful grants program takes considerable time and effort. Take, for instance, the EF Ecosystem Support Program, 
                  which has awarded grants since 2018, consists of an internal team at the Foundation as well as an ever increasing roster of 
                  community advisors in order to keep expanding and adapting to best serve the needs of the Ethereum ecosystem. While the structure 
                  of the allocation committee has six members, we propose that only the lead will be remunerated for their work in establishing the 
                  initial processes, vetting applications, and managing the program overall as this role is expected to be time consuming if the program 
                  is to be succesful. We propose that the other committee members be unpaid UNI ecosystem stakeholders who have an interest in seeing the 
                  protocol ecosystem continue to operate and grow.</p>
              <h4>Conclusion</h4>
              <p>If this proposal is successfully approved, UGP will start accepting applications on a rolling basis beginning at the start of 2021. 
                With the phases and priorities laid out above, UGP will aim to make a significant impact by catalyzing growth and innovation in the UNI ecosystem.</p>
              <h4>Proposer</h4>
              <p>0x76f54Eeb0D33a2A2c5CCb72FE12542A56f35d67C</p>
        </Card.Body>
      </Card>
    </Container>
  )

};

export default Singlevote;
