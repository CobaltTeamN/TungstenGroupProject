import React from 'react';
import Wanted from '../../components/collections/wanted';
import { SpaceAroundRow} from '../../components/styled/Dashboard';
import './Collections.css';

const Collections = () => {
    return (
        <>
        <h2 className="collection-title">Collections Board</h2>
        <p className="collection-info">These borrowers went 14 days past the loan default date.</p>
        <SpaceAroundRow>
        <Wanted/>
        <Wanted/>
        </SpaceAroundRow>
        </>
    )
}

export default Collections;