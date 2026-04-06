import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Spin } from 'antd';
import 'react-quill-new/dist/quill.snow.css'; 
import { systemContentApi } from '../api/systemContentApi';

const PublicPolicyPage = () => {
  const { type } = useParams(); 
  const [content, setContent] = useState('');
  const [title, setTitle] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const cleanContent = (html) => {
    if (!html) return '';
    return html
      .replace(/&nbsp;/g, ' ')  
      .replace(/\s+/g, ' ');
  };

  useEffect(() => {
    const fetchPolicy = async () => {
      setLoading(true);
      setError(false);
      try {
        const res = await systemContentApi.getByTypePublic(type);
        const finalData = res?.data ? res.data : res;

        if (finalData && finalData.title) {
          setTitle(finalData.title);
          setContent(finalData.content);
        } else {
          setError(true);
        }
      } catch (err) {
        console.error("Lỗi tải nội dung:", err);
        setError(true);
      } finally {
        setLoading(false);
      }
    };

    if (type) {
      fetchPolicy();
    }
  }, [type]);

  if (loading) {
    return (
      <div style={{ height: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        <Spin size="large" description="Đang tải nội dung..." />
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ textAlign: 'center', padding: '50px', fontFamily: 'sans-serif' }}>
        <h3>Opps! Không tìm thấy nội dung.</h3>
        <p>Vui lòng kiểm tra lại đường dẫn hoặc thử lại sau.</p>
      </div>
    );
  }

  return (
    <div style={{ 
      backgroundColor: '#f0f2f5', 
      minHeight: '100vh', 
      padding: '40px 16px',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
    }}>
      
      <div style={{ 
        maxWidth: '850px', 
        margin: '0 auto', 
        backgroundColor: '#ffffff', 
        padding: '50px 40px',          
        borderRadius: '12px',    
        boxShadow: '0 4px 20px rgba(0,0,0,0.08)'
      }}>
        
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

          /* Không áp justify cho toàn bộ thẻ con */
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
        `}
        </style>

        <h2 style={{ 
          textAlign: 'center', 
          color: '#1f1f1f', 
          fontSize: '26px', 
          fontWeight: 'bold', 
          marginBottom: '12px' 
        }}>
          {title}
        </h2>

        <div style={{ 
          textAlign: 'center', 
          color: '#8c8c8c', 
          fontSize: '14px', 
          marginBottom: '32px' 
        }}>
          Cập nhật lần cuối: {new Date().toLocaleDateString('vi-VN')}
        </div>
        
        <hr style={{ border: 'none', borderTop: '1px solid #e8e8e8', marginBottom: '32px' }} />
        
        <div 
          className="ql-editor custom-policy-content" 
          style={{ 
            padding: 0, 
            fontSize: '16px',
            lineHeight: '1.8',
            color: '#333' 
          }}
          dangerouslySetInnerHTML={{ __html: cleanContent(content) }} 
        />
        
        <div style={{ 
          textAlign: 'center', 
          marginTop: '50px', 
          paddingTop: '20px',
          borderTop: '1px solid #f0f0f0',
          color: '#bfbfbf', 
          fontSize: '13px' 
        }}>
          © 2026 BeautyBooking System. All rights reserved.
        </div>

      </div>
    </div>
  );
};

export default PublicPolicyPage;