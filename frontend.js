import React, { useState, useEffect } from 'react';

const ControlCenter = () => {
  const [applications, setApplications] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fetch applications from the backend
  useEffect(() => {
    fetch('/api/applications') // Endpoint from our Flask backend
      .then(res => res.json())
      .then(data => {
        setApplications(data);
        setLoading(false);
      });
  }, []);

  // Handle Workflow Status Updates
  const updateStatus = async (id, newStatus) => {
    await fetch(`/api/applications/${id}/status`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: newStatus })
    });
    // Refresh local state to reflect the change
    setApplications(applications.map(app => 
      app.id === id ? { ...app, status: newStatus } : app
    ));
  };

  if (loading) return <div>Loading HR Control Center...</div>;

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h2>HR Control Center: Applicant Management</h2>
      <table border="1" style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ backgroundColor: '#f2f2f2' }}>
            <th>Student Name</th>
            <th>Email</th>
            <th>Job ID</th>
            <th>Current Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {applications.map(app => (
            <tr key={app.id}>
              <td>{app.student_name}</td>
              <td>{app.student_email}</td>
              <td>{app.job_id}</td>
              <td>
                <span style={{ fontWeight: 'bold', color: app.status === 'Hired' ? 'green' : 'orange' }}>
                  {app.status}
                </span>
              </td>
              <td>
                <button onClick={() => updateStatus(app.id, 'Interviewed')}>Move to Interview</button>
                <button onClick={() => updateStatus(app.id, 'Rejected')} style={{ marginLeft: '5px' }}>Reject</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default ControlCenter;