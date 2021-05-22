import React, {useContext} from 'react';
import { Modal, Button } from 'react-bootstrap';
import { GlobalState } from '../GlobalState';

export function TokenSelection(props) {
    const state = useContext(GlobalState)
    const setTokenAddress = state.exchangeAPI.tokenAddress[1];

    function handleToken(e) {
        const token = e.target.childNodes[0].innerText
        console.log(e)
        switch(token) {
            case 'ETH':
                setTokenAddress("0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE")
                break;
            case 'USDT':
                setTokenAddress("0xaf3c38a810670786d2fbd1a40adea7f9dc6e8746")
                break;
            case 'USDC':
                setTokenAddress("0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d");
                break;
            case 'HAM':
                setTokenAddress("0xcde5f4638c82ae3de3cfdf61f3a42327d694926f");
                break;
            default:
                setTokenAddress('0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE')
        }
        console.log(token)
        props.onHide()
    }
    return (
        <Modal
            {...props}
            size="lg"
            aria-labelledby="contained-modal-title-vcenter"
            centered
        >
            <Modal.Header closeButton>
                <div>
                    <Modal.Title className="mb-2" id="contained-modal-title-vcenter">
                        Select a token
                </Modal.Title>
                    <input
                        className="form-input modalinput"
                        type="text"
                        placeholder="Search name or paste address"
                    ></input>
                </div>

            </Modal.Header>
            <Modal.Body>
                <div className="modalbtngroup">
                    <div onClick={(e) => handleToken(e)} className="divbtngroup pt-2 pb-2">
                        <button className="btngroup ml-4"><span>ETH</span><span>0</span></button>
                    </div>
                    <div className="divbtngroup pt-2 pb-2">
                        <button onClick={(e) => handleToken(e)} className="btngroup ml-4 mt-4"><span>USDT</span><span>0</span></button>
                    </div>
                    <div className="divbtngroup pt-2 pb-2">
                        <button onClick={(e) => handleToken(e)} className="btngroup ml-4 mt-4"><span>USDC</span><span>0</span></button>
                    </div>
                    <div className="divbtngroup pt-2 pb-2">
                        <button onClick={(e) => handleToken(e)} className="btngroup ml-4 mt-4"><span>HAM</span><span>0</span></button>
                    </div>
                </div>

            </Modal.Body>
            <Modal.Footer>
                <Button className="m-auto" >Manage</Button>
            </Modal.Footer>
        </Modal>
    );
}