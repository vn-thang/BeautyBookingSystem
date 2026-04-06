import React, { useEffect, useState } from 'react';
import { Spin, Tabs } from 'antd';
import 'react-quill-new/dist/quill.snow.css'; 
import { systemContentApi } from '../api/systemContentApi';

const AllPoliciesPage = () => {
  const [loading, setLoading] = useState(true);
  const [terms, setTerms] = useState(null);
  const [privacy, setPrivacy] = useState(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    const fetchAllPolicies = async () => {
      setLoading(true);
      try {
        const [termsRes, privacyRes] = await Promise.all([
          systemContentApi.getByTypePublic(1), 
          systemContentApi.getByTypePublic(2)
        ]);

        setTerms(termsRes?.data ? termsRes.data : termsRes);
        setPrivacy(privacyRes?.data ? privacyRes.data : privacyRes);
      } catch (err) {
        console.error("Lỗi tải nội dung:", err);
        setError(true);
      } finally {
        setLoading(false);
      }
    };

    fetchAllPolicies();
  }, []);

  if (loading) {
    return (
      <div style={{ height: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        <Spin size="large" description="Đang tải hệ thống chính sách..." />
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ textAlign: 'center', padding: '50px' }}>
        <h3>Opps! Không thể tải chính sách.</h3>
        <p>Vui lòng thử lại sau.</p>
      </div>
    );
  }

  
  const cleanContent = (html) => {
  if (!html) return '';
  return html
    .replace(/&nbsp;/g, ' ')
    .replace(/\s+/g, ' ');
};

 const renderTabContent = (data) => {
  if (!data || !data.content) return <p>Nội dung đang được cập nhật...</p>;
  return (
    <div
      className="ql-editor custom-policy-content"
      style={{ padding: 0, fontSize: '16px', lineHeight: '1.8', color: '#333' }}
      dangerouslySetInnerHTML={{ __html: cleanContent(data.content) }} 
    />
  );
};

  const tabItems = [
    {
      key: '1',
      label: <span style={{ fontSize: '16px', fontWeight: 500 }}>Điều khoản sử dụng</span>,
      children: renderTabContent(terms),
    },
    {
      key: '2',
      label: <span style={{ fontSize: '16px', fontWeight: 500 }}>Chính sách bảo mật</span>,
      children: renderTabContent(privacy),
    }
  ];

  return (
    <div style={{ backgroundColor: '#f0f2f5', minHeight: '100vh', padding: '40px 16px', fontFamily: 'sans-serif' }}>
      <div style={{ maxWidth: '850px', margin: '0 auto', backgroundColor: '#ffffff', padding: '40px', borderRadius: '12px', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
        
      <style>
{`
  .custom-policy-content {
    text-align: justify;

    word-break: normal;
    overflow-wrap: break-word;

    white-space: normal;

    -webkit-hyphens: none;
    -ms-hyphens: none;
    hyphens: none;
  }

  /* KHÔNG justify toàn bộ thẻ con */
  .custom-policy-content * {
    word-break: normal;
    white-space: normal;
  }

  /* Fix Quill */
  .ql-editor {
    white-space: normal !important;
    word-break: normal !important;
    overflow-wrap: break-word !important;
  }

  .custom-policy-content ul,
  .custom-policy-content ol {
    padding-left: 24px;
  }

  .custom-policy-content h1,
  .custom-policy-content h2,
  .custom-policy-content h3 {
    text-align: left;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
  }

  .ant-tabs-nav { margin-bottom: 30px; }
  .ant-tabs-tab.ant-tabs-tab-active .ant-tabs-tab-btn { color: #4318FF; }
  .ant-tabs-ink-bar { background: #4318FF; }
`}
</style>
        <h2 style={{ textAlign: 'center', color: '#1f1f1f', fontSize: '26px', fontWeight: 'bold', marginBottom: '12px' }}>
          Trung tâm Chính sách & Điều khoản
        </h2>
        <div style={{ textAlign: 'center', color: '#8c8c8c', fontSize: '14px', marginBottom: '24px' }}>
          BeautyBooking System
        </div>

        <Tabs defaultActiveKey="1" items={tabItems} centered />

        <div style={{ textAlign: 'center', marginTop: '50px', paddingTop: '20px', borderTop: '1px solid #f0f0f0', color: '#bfbfbf', fontSize: '13px' }}>
          © {new Date().getFullYear()} BeautyBooking System. All rights reserved.
        </div>

      </div>
    </div>
  );
};

export default AllPoliciesPage;